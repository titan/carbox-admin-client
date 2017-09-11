import 'dart:async';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/api/upgrade.dart' as api;
import 'package:adminclient/model/upgrade.dart';
import 'package:adminclient/store/defination.dart';
import 'package:adminclient/store/session.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

const String upgradekey = 'upgrade';

class UpgradeState {
  int total = 0;
  int offset = 0;
  List<Upgrade> data = <Upgrade>[];
  Upgrade selected = null;
  Upgrade toDelete = null;
  bool loading = false;
  bool editing = false;
  bool deleting = false;
  bool deletable = false;
  bool nomore = false;
  Exception error = null;
}

class UpgradeActionPayload {
  final String tag;
  final int offset;
  final int limit;
  final int state;
  final Exception error;
  final CollectionResponse<Upgrade> response;
  final Upgrade selected;
  UpgradeActionPayload({
    this.tag = "selected",
    this.offset = 0,
    this.limit = 20,
    this.state = 1,
    this.error,
    this.response,
    this.selected,
  });
}

class UpgradeAction implements Action {
  String type;
  UpgradeActionPayload payload;
  bool error;
  String meta;
  UpgradeAction({
    this.type,
    this.payload,
    this.error,
    this.meta = upgradekey,
  });
}

class UpgradeReducer extends ReducerClass<Map<String, UpgradeState>> {
  Map<String, UpgradeState> call(
      Map<String, UpgradeState> states, UpgradeAction action) {
    String tag = action.payload.tag;
    UpgradeState state = states[tag];
    switch (action.type) {
      case 'FETCH_UPGRADES_REQUEST':
        state.loading = true;
        return states;
      case 'FETCH_UPGRADES_SUCCESS':
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
      case 'FETCH_UPGRADES_FAILED':
        state.loading = false;
        state.error = action.payload.error;
        return states;
      case 'SELECT_UPGRADE':
        state.selected = action.payload.selected;
        if (state.selected == null) {
          state.editing = true;
          state.error = null;
        } else {
          state.editing = false;
        }
        return states;
      case 'EDIT_UPGRADE':
        state.editing = true;
        return states;
      case 'CREATE_UPGRADE_REQUEST':
        state.loading = true;
        return states;
      case 'CREATE_UPGRADE_SUCCESS':
        <String>["testing"]
            .forEach((String x) {
          states[x] = new UpgradeState();
        });
        state.loading = false;
        state.editing = false;
        state.selected = action.payload.selected;
        return states;
      case 'CREATE_UPGRADE_FAILED':
        state.loading = false;
        state.error = action.payload.error;
        return states;
      case 'FETCH_UPGRADE_REQUEST':
        state.loading = true;
        return states;
      case 'FETCH_UPGRADE_SUCCESS':
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
      case 'FETCH_UPGRADE_FAILED':
        state.loading = false;
        state.error = action.payload.error;
        return states;
      case 'MODIFY_UPGRADE_REQUEST':
        state.loading = true;
        return states;
      case 'MODIFY_UPGRADE_SUCCESS':
        <String>["testing", "failed", "releasing", "released"]
            .forEach((String x) {
          states[x] = new UpgradeState();
        });
        state.loading = false;
        state.editing = false;
        return states;
      case 'MODIFY_UPGRADE_FAILED':
        state.loading = false;
        state.error = action.payload.error;
        return states;
      case 'DELETE_UPGRADE_REQUEST':
        state.deleting = true;
        state.toDelete = action.payload.selected;
        return states;
      case 'DELETE_UPGRADE_SUCCESS':
        state.deleting = false;
        state.data = state.data.where((x) => x != action.payload.selected).toList();
        return states;
      case 'DELETE_UPGRADE_FAILED':
        state.deleting = false;
        state.error = action.payload.error;
        return states;
      case 'DISPLAY_DELETE_UPGRADE_ACTION':
        state.deletable = true;
        return states;
      case 'HIDE_DELETE_UPGRADE_ACTION':
        state.deletable = false;
        return states;
      default:
        return states;
    }
  }
}

Stream<Action> fetchUpgradesEpic(
    Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is UpgradeAction && action.type == 'FETCH_UPGRADES_REQUEST')
      .map((action) => (action as UpgradeAction).payload)
      .asyncMap((payload) => api
              .fetchUpgrades(
                session: store.state.getState(sessionkey).session,
                state: payload.state,
                offset: payload.offset,
                limit: payload.limit,
              )
              .then((CollectionResponse<Upgrade> response) => new UpgradeAction(
                    type: 'FETCH_UPGRADES_SUCCESS',
                    payload: new UpgradeActionPayload(
                      response: response,
                      tag: payload.tag,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            if (error is Error) {
              print(error.stackTrace);
            }
            return new UpgradeAction(
              type: 'FETCH_UPGRADES_FAILED',
              payload: new UpgradeActionPayload(
                tag: payload.tag,
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

Stream<Action> fetchUpgradeEpic(
    Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is UpgradeAction && action.type == 'FETCH_UPGRADE_REQUEST')
      .map((action) => (action as UpgradeAction).payload)
      .asyncMap((payload) => api
              .fetchUpgrade(
                session: store.state.getState(sessionkey).session,
                id: payload.id,
              )
              .then((CollectionResponse<Upgrade> response) => new UpgradeAction(
                    type: 'FETCH_UPGRADE_SUCCESS',
                    payload: new UpgradeActionPayload(
                      response: response,
                      tag: payload.tag,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            if (error is Error) {
              print(error.stackTrace);
            }
            return new UpgradeAction(
              type: 'FETCH_UPGRADE_FAILED',
              payload: new UpgradeActionPayload(
                tag: payload.tag,
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

Stream<Action> deleteUpgradeEpic(
    Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is UpgradeAction && action.type == 'DELETE_UPGRADE_REQUEST')
      .map((action) => (action as UpgradeAction).payload)
      .asyncMap((payload) => api
              .deleteUpgrade(
                session: store.state.getState(sessionkey).session,
                id: payload.selected.id,
              )
              .then((bool okay) => new UpgradeAction(
                    type: 'DELETE_UPGRADE_SUCCESS',
                    payload: new UpgradeActionPayload(
                      tag: payload.tag,
                      selected: payload.selected,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            print(error);
            if (error is Error) {
              print(error.stackTrace);
            }
            return new UpgradeAction(
              type: 'DELETE_UPGRADE_FAILED',
              payload: new UpgradeActionPayload(
                tag: payload.tag,
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

Stream<Action> createUpgradeEpic(
    Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is UpgradeAction && action.type == 'CREATE_UPGRADE_REQUEST')
      .map((action) => (action as UpgradeAction).payload)
      .asyncMap((payload) => api
              .createUpgrade(
                session: store.state.getState(sessionkey).session,
                state: payload.selected.state,
                url: payload.selected.url,
                type: payload.selected.type,
                systemBoard: payload.selected.systemBoard,
                lockBoard: payload.selected.lockBoard,
                version: payload.selected.version,
              )
              .then((Upgrade upgrade) => new UpgradeAction(
                    type: 'CREATE_UPGRADE_SUCCESS',
                    payload: new UpgradeActionPayload(
                      selected: upgrade,
                      tag: payload.tag,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            if (error is Error) {
              print(error.stackTrace);
            }
            return new UpgradeAction(
              type: 'CREATE_UPGRADE_FAILED',
              payload: new UpgradeActionPayload(
                tag: payload.tag,
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

Stream<Action> modifyUpgradeEpic(
    Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is UpgradeAction && action.type == 'MODIFY_UPGRADE_REQUEST')
      .map((action) => (action as UpgradeAction).payload)
      .asyncMap((payload) => api
              .modifyUpgrade(
                session: store.state.getState(sessionkey).session,
                state: payload.selected.state,
                url: payload.selected.url,
                type: payload.selected.type,
                systemBoard: payload.selected.systemBoard,
                lockBoard: payload.selected.lockBoard,
                id: payload.selected.id,
                version: payload.selected.version,
              )
              .then((Upgrade upgrade) => new UpgradeAction(
                    type: 'MODIFY_UPGRADE_SUCCESS',
                    payload: new UpgradeActionPayload(
                      selected: upgrade,
                      tag: payload.tag,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            print(error);
            if (error is Error) {
              print(error.stackTrace);
            }
            return new UpgradeAction(
              type: 'MODIFY_UPGRADE_FAILED',
              payload: new UpgradeActionPayload(
                tag: payload.tag,
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

void selectUpgrade(Store store, Upgrade upgrade) {
  store.dispatch(new UpgradeAction(
    type: 'SELECT_UPGRADE',
    payload: new UpgradeActionPayload(
      tag: "selected",
      selected: upgrade,
    ),
  ));
}

void fetchUpgrades(Store store, String tag, int state, int offset) {
  store.dispatch(new UpgradeAction(
    type: 'FETCH_UPGRADES_REQUEST',
    payload: new UpgradeActionPayload(
      tag: tag,
      state: state,
      offset: offset,
    ),
  ));
}

void fetchUpgrade(Store store, int id, int offset) {
  store.dispatch(new UpgradeAction(
    type: 'FETCH_UPGRADE_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "fetchupgrade",
      id: id,
      offset: offset,
    ),
  ));
}

void createUpgrade(Store store, Upgrade upgrade) {
  store.dispatch(new UpgradeAction(
    type: 'CREATE_UPGRADE_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "selected",
      selected: upgrade,
    ),
  ));
}

void modifyUpgrade(Store store, Upgrade upgrade) {
  store.dispatch(new UpgradeAction(
    type: 'MODIFY_UPGRADE_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "selected",
      selected: upgrade,
    ),
  ));
}

void deleteUpgrade(Store store, String tag, Upgrade upgrade) {
  store.dispatch(new UpgradeAction(
    type: 'DELETE_UPGRADE_REQUEST',
    payload: new UpgradeActionPayload(
      tag: tag,
      selected: upgrade,
    ),
  ));
}

void editUpgrade(Store store) {
  store.dispatch(new UpgradeAction(
    type: 'EDIT_UPGRADE',
    payload: new UpgradeActionPayload(
      tag: "selected",
    ),
  ));
}

void displayDeleteUpgradeAction(Store store, String tag) {
  store.dispatch(new UpgradeAction(
    type: 'DISPLAY_DELETE_UPGRADE_ACTION',
    payload: new UpgradeActionPayload(
      tag: tag,
    ),
  ));
}

void hideDeleteUpgradeAction(Store store, String tag) {
  store.dispatch(new UpgradeAction(
    type: 'HIDE_DELETE_UPGRADE_ACTION',
    payload: new UpgradeActionPayload(
      tag: tag,
    ),
  ));
}
