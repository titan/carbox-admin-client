import 'dart:async';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/api/upgrade.dart' as api;
import 'package:adminclient/model/upgrade.dart';
// import 'package:adminclient/model/session.dart';
import 'package:adminclient/store/defination.dart';
import 'package:adminclient/store/session.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

const String upgradekey = 'upgrade';

class UpgradeState {
  int total = 0;
  int offset = 0;
  String id = "";
  List<Upgrade> data = <Upgrade>[];
  Upgrade selected = null;
  Upgrade put = null;
  bool loading = false;
  bool nomore = false;
  bool reload = false;
  bool postend = false;
  bool putend = false;
  bool deleted = false;
  bool putWaiting = false;
  // bool postWaiting = false;
  Exception error = null;
}

class UpgradeActionPayload {
  final String tag;
  // final String key;
  final int id;
  final int offset;
  final int limit;
  final int state;
  final Exception error;
  final CollectionResponse<Upgrade> response;
  final Map<String, dynamic> postResponse;
  final Upgrade selected;
  final Upgrade postWaiting;
  final Upgrade testWaiting;
  final Upgrade putWaiting;
  final Upgrade upgrade;
  UpgradeActionPayload({
    this.tag = "fetchupgrades",
    this.id = 0,
    this.offset = 0,
    this.limit = 20,
    this.state = 1,
    this.error,
    this.response,
    this.selected,
    this.postWaiting,
    this.testWaiting,
    this.putWaiting,
    this.postResponse,
    this.upgrade,
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

class UpgradeReducer extends Reducer<Map<String, UpgradeState>, UpgradeAction> {
  reduce(Map<String, UpgradeState> states, UpgradeAction action) {
    String tag = action.payload.tag;
    UpgradeState state = states[tag];
    switch (action.type) {
      case 'FETCH_UPGRADES_REQUEST':
        state.loading = true;
        state.reload = false;
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
      case 'UPGRADE_SELECT':
        state.selected = action.payload.selected;
        return states;
      case 'UPGRADE_SAVE_PUT':
        state.put = action.payload.putWaiting;
        state.putWaiting = true;
        return states;
      case 'RELOAD_UPGRADE':
        state.reload = true;
        return states;
      case 'POST_UPGRADE_WAITING_REQUEST':
        state.put = null;
        state.putWaiting = false;
        return states;
      case 'POST_UPGRADE_REQUEST':
        state.loading = true;
        state.postend = false;
        return states;
      case 'POST_UPGRADE_FAILED':
        state.loading = false;
        state.postend = true;
        state.error = action.payload.error;
        return states;
      case 'POST_UPGRADE_SUCCESS':
        UpgradeState newState = states["select"];
        var response = action.payload.postResponse;
        var res = new Upgrade();
        res.state = response["state"];
        res.systemBoard = response["system-board"];
        res.url = response["url"];
        res.lockBoard = response["lock-boadr"];
        res.version = response["version"];
        res.id = response["id"];
        res.type = response["type"];
        res.constraint = response["constraint"];
        state.loading = false;
        state.postend = true;
        state.selected = res;
        newState.selected = res;
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
      case 'PUT_UPGRADE_REQUEST':
        state.loading = true;
        state.putend = false;
        return states;
      case 'PUT_UPGRADE_SUCCESS':
        UpgradeState new1State = states["select"];
        var response = action.payload.postResponse;
        var res = new Upgrade();
        res.state = response["state"];
        res.systemBoard = response["system-board"];
        res.url = response["url"];
        res.lockBoard = response["lock-boadr"];
        res.version = response["version"];
        res.id = response["id"];
        res.type = response["type"];
        res.constraint = response["constraint"];
        state.loading = false;
        state.postend = true;
        state.selected = res;
        new1State.selected = res;
        state.putWaiting = false;
        state.putend = true;
        return states;
      case 'PUT_UPGRADE_FAILED':
        state.loading = false;
        state.putend = true;
        state.error = action.payload.error;
        return states;
      case 'DELETE_UPGRADE_REQUEST':
        state.loading = true;
        state.deleted = false;
        return states;
      case 'DELETE_UPGRADE_SUCCESS':
        state.loading = false;
        state.deleted = true;
        return states;
      case 'DELETE_UPGRADE_FAILED':
        state.loading = false;
        state.deleted = true;
        state.error = action.payload.error;
        return states;
      default:
        return states;
    }
  }
}

class FetchUpgradesEpic extends Epic<AppState, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<AppState, Action> store) {
    return actions
        .where((action) =>
            action is UpgradeAction && action.type == 'FETCH_UPGRADES_REQUEST')
        .map((action) => (action as UpgradeAction).payload)
        .asyncMap((payload) => api
                .fetchgrades(
                  session: store.state.getState(sessionkey).session,
                  state: payload.state,
                  offset: payload.offset,
                  limit: payload.limit,
                )
                .then(
                    (CollectionResponse<Upgrade> response) => new UpgradeAction(
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
}

class FetchUpgradeEpic extends Epic<AppState, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<AppState, Action> store) {
    return actions
        .where((action) =>
            action is UpgradeAction && action.type == 'FETCH_UPGRADE_REQUEST')
        .map((action) => (action as UpgradeAction).payload)
        .asyncMap((payload) => api
                .fetchgrade(
                  session: store.state.getState(sessionkey).session,
                  id: payload.id,
                )
                .then(
                    (CollectionResponse<Upgrade> response) => new UpgradeAction(
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
}

class DeleteUpgradeEpic extends Epic<AppState, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<AppState, Action> store) {
    return actions
        .where((action) =>
            action is UpgradeAction && action.type == 'DELETE_UPGRADE_REQUEST')
        .map((action) => (action as UpgradeAction).payload)
        .asyncMap((payload) => api
                .deleteUpgrade(
                  session: store.state.getState(sessionkey).session,
                  id: payload.id,
                )
                .then(
                    (CollectionResponse<Upgrade> response) => new UpgradeAction(
                          type: 'DELETE_UPGRADE_SUCCESS',
                          payload: new UpgradeActionPayload(
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
}

class PostUpgradeEpic extends Epic<AppState, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<AppState, Action> store) {
    return actions
        .where((action) =>
            action is UpgradeAction && action.type == 'POST_UPGRADE_REQUEST')
        .map((action) => (action as UpgradeAction).payload)
        .asyncMap((payload) => api
                .postUpgrade(
                  session: store.state.getState(sessionkey).session,
                  state: payload.postWaiting.state,
                  url: payload.postWaiting.url,
                  type: payload.postWaiting.type,
                  systemBoard: payload.postWaiting.systemBoard,
                  lockBoard: payload.postWaiting.lockBoard,
                  version: payload.postWaiting.version,
                  constraint: payload.postWaiting.constraint,
                )
                .then((Map<String, dynamic> response) => new UpgradeAction(
                      type: 'POST_UPGRADE_SUCCESS',
                      payload: new UpgradeActionPayload(
                        postResponse: response,
                        tag: payload.tag,
                      ),
                      error: false,
                    ))
                .catchError((error) {
              if (error is Error) {
                print(error.stackTrace);
              }
              return new UpgradeAction(
                type: 'POST_UPGRADE_FAILED',
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
}

class PutUpgradeEpic extends Epic<AppState, Action> {
  @override
  Stream<Action> map(
      Stream<Action> actions, EpicStore<AppState, Action> store) {
    return actions
        .where((action) =>
            action is UpgradeAction && action.type == 'PUT_UPGRADE_REQUEST')
        .map((action) => (action as UpgradeAction).payload)
        .asyncMap((payload) => api
                .putUpgrade(
                  session: store.state.getState(sessionkey).session,
                  state: payload.putWaiting.state,
                  url: payload.putWaiting.url,
                  type: payload.putWaiting.type,
                  systemBoard: payload.putWaiting.systemBoard,
                  lockBoard: payload.putWaiting.lockBoard,
                  id: payload.putWaiting.id,
                  version: payload.putWaiting.version,
                  constraint: payload.putWaiting.constraint,
                )
                .then((Map<String, dynamic> response) => new UpgradeAction(
                      type: 'PUT_UPGRADE_SUCCESS',
                      payload: new UpgradeActionPayload(
                        postResponse: response,
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
                type: 'PUT_UPGRADE_FAILED',
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
}

void selectUpgrade(Store store, Upgrade upgrade) {
  store.dispatch(new UpgradeAction(
    type: 'UPGRADE_SELECT',
    payload: new UpgradeActionPayload(
      tag: "select",
      selected: upgrade,
    ),
  ));
}

void savePutUpgrade(Store store, Upgrade upgrade) {
  store.dispatch(new UpgradeAction(
    type: 'UPGRADE_SAVE_PUT',
    payload: new UpgradeActionPayload(
      tag: "putupgrade",
      putWaiting: upgrade,
    ),
  ));
}

void fetch1Upgrades(Store store, int offset) {
  store.dispatch(new UpgradeAction(
    type: 'FETCH_UPGRADES_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "test-waiting",
      state: 1,
      offset: offset,
    ),
  ));
}

void fetch2Upgrades(Store store, int offset) {
  store.dispatch(new UpgradeAction(
    type: 'FETCH_UPGRADES_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "test-failed",
      state: -1,
      offset: offset,
    ),
  ));
}

void fetch3Upgrades(Store store, int offset) {
  store.dispatch(new UpgradeAction(
    type: 'FETCH_UPGRADES_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "publish-waiting",
      state: 2,
      offset: offset,
    ),
  ));
}

void fetch4Upgrades(Store store, int offset) {
  store.dispatch(new UpgradeAction(
    type: 'FETCH_UPGRADES_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "published",
      state: 15,
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

void postUpgrade(Store store, Upgrade upgrade) {
  store.dispatch(new UpgradeAction(
    type: 'POST_UPGRADE_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "postupgrade",
      postWaiting: upgrade,
    ),
  ));
}

void postWaiting(Store store) {
  store.dispatch(new UpgradeAction(
    type: 'POST_UPGRADE_WAITING_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "putupgrade",
      // postWaiting: upgrade,
    ),
  ));
}

void putUpgrade(Store store, Upgrade upgrade) {
  store.dispatch(new UpgradeAction(
    type: 'PUT_UPGRADE_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "putupgrade",
      putWaiting: upgrade,
    ),
  ));
}

void deleteUpgrade(Store store, int id) {
  store.dispatch(new UpgradeAction(
    type: 'DELETE_UPGRADE_REQUEST',
    payload: new UpgradeActionPayload(
      tag: "deleteupgrade",
      id: id,
    ),
  ));
}

void reloadUpgrade(Store store, String key) {
  store.dispatch(new UpgradeAction(
    type: 'RELOAD_UPGRADE',
    payload: new UpgradeActionPayload(
      tag: key,
    ),
  ));
}
