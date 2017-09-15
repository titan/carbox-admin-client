import 'dart:async';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/api/device.dart' as api;
import 'package:adminclient/model/device.dart';
import 'package:adminclient/store/defination.dart';
import 'package:adminclient/store/session.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

const String devicekey = 'device';

class DeviceState {
  int total = 0;
  int offset = 0;
  String pin = ""; // available in unregistered device state
  List<Device> data = <Device>[];
  Device selected = null;
  bool loading = false;
  bool nomore = false;
  bool editing = false;
  Exception error = null;
}

class DeviceActionPayload {
  final String tag;
  final String pin;
  final int offset;
  final int limit;
  final Exception error;
  final CollectionResponse<Device> response;
  final Device selected;
  DeviceActionPayload({
    this.tag = "registered",
    this.pin = "",
    this.offset = 0,
    this.limit = 20,
    this.error,
    this.response,
    this.selected,
  });
}

class DeviceAction implements Action {
  String type;
  DeviceActionPayload payload;
  bool error;
  String meta;
  DeviceAction({
    this.type,
    this.payload,
    this.error,
    this.meta = devicekey,
  });
}

class DeviceReducer extends ReducerClass<Map<String, DeviceState>> {
  Map<String, DeviceState> call(
      Map<String, DeviceState> states, DeviceAction action) {
    String tag = action.payload.tag;
    DeviceState state = states[tag];
    switch (action.type) {
      case 'FETCH_UNREGISTERED_DEVICES_REQUEST':
      case 'FETCH_REGISTERED_DEVICES_REQUEST':
      case 'REGISTER_DEVICE_REQUEST':
      case 'MODIFY_DEVICE_REQUEST':
        state.loading = true;
        return states;
      case 'FETCH_UNREGISTERED_DEVICES_SUCCESS':
      case 'FETCH_REGISTERED_DEVICES_SUCCESS':
        var response = action.payload.response;
        state.loading = false;
        state.nomore =
            (response.data.length + state.data.length >= response.total);
        state.total = response.total;
        state.offset = response.offset;
        if (response.offset == 0) {
          state.data = response.data;
        } else {
          state.data.addAll(response.data);
        }
        return states;
      case 'FETCH_UNREGISTERED_DEVICES_FAILED':
      case 'FETCH_REGISTERED_DEVICES_FAILED':
      case 'REGISTER_DEVICE_FAILED':
      case 'MODIFY_DEVICE_FAILED':
        state.loading = false;
        state.error = action.payload.error;
        return states;
      case 'SELECT_UNREGISTERED_DEVICE':
        state.selected = action.payload.selected;
        state.editing = true;
        state.error = null;
        return states;
      case 'SELECT_REGISTERED_DEVICE':
        state.selected = action.payload.selected;
        if (state.selected == null) {
          state.editing = true;
          state.error = null;
        } else {
          state.editing = false;
        }
        return states;
      case 'EDIT_DEVICE':
        state.editing = true;
        return states;
      case 'MODIFY_DEVICE_SUCCESS':
        List rows = states["registered"].data;
        for (int i = 0; i < rows.length; i ++) {
          if (rows[i].mac == action.payload.selected.mac) {
            rows[i] = action.payload.selected;
            break;
          }
        }
        state.loading = false;
        state.editing = false;
        state.selected = action.payload.selected;
        return states;
      case 'REGISTER_DEVICE_SUCCESS':
        List rows = states["unregistered"].data;
        for (int i = 0; i < rows.length; i ++) {
          if (rows[i].mac == action.payload.selected.mac) {
            rows.removeAt(i);
            if (states["regiestered"] != null && states["registered"].data.length > 0) {
              states["registered"].data.add(action.payload.selected);
            } else {
              states["registered"] = new DeviceState();
            }
            break;
          }
        }
        state.loading = false;
        state.editing = false;
        state.selected = action.payload.selected;
        return states;
      default:
        return states;
    }
  }
}

Stream<Action> fetchUnregisteredDeviceEpic(
    Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is DeviceAction &&
          action.type == 'FETCH_UNREGISTERED_DEVICES_REQUEST')
      .map((action) => (action as DeviceAction).payload)
      .asyncMap((payload) => api
              .fetchUnregisteredDevices(
                session: store.state.getState(sessionkey).session,
                pin: payload.pin,
                offset: payload.offset,
                limit: payload.limit,
              )
              .then((CollectionResponse<Device> response) => new DeviceAction(
                    type: 'FETCH_UNREGISTERED_DEVICES_SUCCESS',
                    payload: new DeviceActionPayload(
                      response: response,
                      tag: payload.tag,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            print(error);
            if (error is Error) {
              print(error.stackTrace);
            }
            return new DeviceAction(
              type: 'FETCH_UNREGISTERED_DEVICES_FAILED',
              payload: new DeviceActionPayload(
                tag: payload.tag,
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

Stream<Action> fetchRegisteredDeviceEpic(
    Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is DeviceAction &&
          action.type == 'FETCH_REGISTERED_DEVICES_REQUEST')
      .map((action) => (action as DeviceAction).payload)
      .asyncMap((payload) => api
              .fetchRegisteredDevices(
                session: store.state.getState(sessionkey).session,
                offset: payload.offset,
                limit: payload.limit,
              )
              .then((CollectionResponse<Device> response) => new DeviceAction(
                    type: 'FETCH_REGISTERED_DEVICES_SUCCESS',
                    payload: new DeviceActionPayload(
                      response: response,
                      tag: payload.tag,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            print(error);
            if (error is Error) {
              print(error.stackTrace);
            }
            return new DeviceAction(
              type: 'FETCH_REGISTERED_DEVICES_FAILED',
              payload: new DeviceActionPayload(
                tag: payload.tag,
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

Stream<Action> registerDeviceEpic(
    Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is DeviceAction && action.type == 'REGISTER_DEVICE_REQUEST')
      .map((action) => (action as DeviceAction).payload)
      .asyncMap((payload) => api
              .registerDevice(
                session: store.state.getState(sessionkey).session,
                mac: payload.selected.mac,
                address: payload.selected.address,
                pin: payload.selected.pin,
                systemBoard: payload.selected.systemBoard,
                lockBoard: payload.selected.lockBoard,
                lockAmount: payload.selected.lockAmount,
                wireless: payload.selected.wireless,
                antenna: payload.selected.antenna,
                cardReader: payload.selected.cardReader,
                speaker: payload.selected.speaker,
                simNo: payload.selected.simNo ?? 0,
                routerBoard: payload.selected.routerBoard,
              )
              .then((Device device) => new DeviceAction(
                    type: 'REGISTER_DEVICE_SUCCESS',
                    payload: new DeviceActionPayload(
                      selected: device,
                      tag: payload.tag,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            print(error);
            if (error is Error) {
              print(error.stackTrace);
            }
            return new DeviceAction(
              type: 'REGISTER_DEVICE_FAILED',
              payload: new DeviceActionPayload(
                tag: payload.tag,
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

Stream<Action> modifyDeviceEpic(
    Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is DeviceAction && action.type == 'MODIFY_DEVICE_REQUEST')
      .map((action) => (action as DeviceAction).payload)
      .asyncMap((payload) => api
              .modifyDevice(
                session: store.state.getState(sessionkey).session,
                mac: payload.selected.mac,
                address: payload.selected.address,
                systemBoard: payload.selected.systemBoard,
                lockBoard: payload.selected.lockBoard,
                lockAmount: payload.selected.lockAmount,
                wireless: payload.selected.wireless,
                antenna: payload.selected.antenna,
                cardReader: payload.selected.cardReader,
                speaker: payload.selected.speaker,
                simNo: payload.selected.simNo,
                routerBoard: payload.selected.routerBoard,
              )
              .then((Device device) => new DeviceAction(
                    type: 'MODIFY_DEVICE_SUCCESS',
                    payload: new DeviceActionPayload(
                      selected: device,
                      tag: payload.tag,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            print(error);
            if (error is Error) {
              print(error.stackTrace);
            }
            return new DeviceAction(
              type: 'MODIFY_DEVICE_FAILED',
              payload: new DeviceActionPayload(
                tag: payload.tag,
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

void fetchUnregisteredDevices(Store store, String pin, int offset) {
  store.dispatch(new DeviceAction(
    type: 'FETCH_UNREGISTERED_DEVICES_REQUEST',
    payload: new DeviceActionPayload(
      tag: "unregistered",
      pin: pin,
      offset: offset,
    ),
  ));
}

void selectUnregisteredDevice(Store store, Device device) {
  store.dispatch(new DeviceAction(
    type: 'SELECT_UNREGISTERED_DEVICE',
    payload: new DeviceActionPayload(
      tag: "selected",
      selected: device,
    ),
  ));
}

void fetchRegisteredDevices(Store store, int offset) {
  store.dispatch(new DeviceAction(
    type: 'FETCH_REGISTERED_DEVICES_REQUEST',
    payload: new DeviceActionPayload(
      tag: "registered",
      offset: offset,
    ),
  ));
}

void selectRegisteredDevice(Store store, Device device) {
  store.dispatch(new DeviceAction(
    type: 'SELECT_REGISTERED_DEVICE',
    payload: new DeviceActionPayload(
      tag: "selected",
      selected: device,
    ),
  ));
}

void registerDevice(Store store, Device device) {
  store.dispatch(new DeviceAction(
    type: 'REGISTER_DEVICE_REQUEST',
    payload: new DeviceActionPayload(
      tag: "selected",
      selected: device,
    ),
  ));
}

void modifyDevice(Store store, Device device) {
  store.dispatch(new DeviceAction(
    type: 'MODIFY_DEVICE_REQUEST',
    payload: new DeviceActionPayload(
      tag: "selected",
      selected: device,
    ),
  ));
}

void editDevice(Store store) {
  store.dispatch(new DeviceAction(
    type: 'EDIT_DEVICE',
    payload: new DeviceActionPayload(
      tag: "selected",
    ),
  ));
}
