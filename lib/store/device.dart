import 'dart:async';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/api/device.dart' as api;
import 'package:adminclient/model/device.dart';
import 'package:adminclient/model/session.dart';
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
  Device unregisteredSelected = null;
  bool loading = false;
  bool nomore = false;
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

class DeviceReducer extends Reducer<Map<String, DeviceState>, DeviceAction> {
  reduce(Map<String, DeviceState> states, DeviceAction action) {
    String tag = action.payload.tag;
    DeviceState state = states[tag];
    switch (action.type) {
      case 'UNREGISTERED_DEVICES_REQUEST':
        state.loading = true;
        return states;
      case 'UNREGISTERED_DEVICES_SUCCESS':
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
      case 'UNREGISTERED_DEVICES_FAILED':
        state.loading = false;
        state.error = action.payload.error;
        return states;
      case 'UNREGISTERED_DEVICES_SELECT':
        state.unregisteredSelected = action.payload.unregisteredSelected;
        return states;
      default:
        return states;
    }
  }
}

class DeviceEpic extends Epic<AppState, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<AppState, Action> store) {
    return actions
        .where((action) =>
            action is DeviceAction &&
            action.type == 'UNREGISTERED_DEVICES_REQUEST')
        .map((action) => (action as DeviceAction).payload)
        .asyncMap((payload) => api
                .fetchUnregisteredDevices(
                  session: store.state.getState(sessionkey).session,
                  pin: payload.pin,
                  offset: payload.offset,
                  limit: payload.limit,
                )
                .then((CollectionResponse<Device> response) => new DeviceAction(
                      type: 'UNREGISTERED_DEVICES_SUCCESS',
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
                type: 'UNREGISTERED_DEVICES_FAILED',
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
}

void fetchUnregisteredDevices(Store store, String pin, int offset) {
  store.dispatch(new DeviceAction(
    type: 'UNREGISTERED_DEVICES_REQUEST',
    payload: new DeviceActionPayload(
      tag: "unregistered",
      pin: pin,
      offset: offset,
    ),
  ));
}

void selectUnreigsteredDevice(Store store, Device device) {
  store.dispatch(new DeviceAction(
    type: 'UNREGISTERED_DEVICES_SELECT',
    payload: new DeviceActionPayload(
      tag: "unregistered",
      selected: device,
    ),
  ));
}
