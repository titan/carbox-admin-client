import 'package:adminclient/store/defination.dart';
import 'package:adminclient/store/session.dart';
import 'package:adminclient/store/device.dart';
import 'package:adminclient/store/upgrade.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

class AppReducer extends ReducerClass<AppState> {
  Map<String, ReducerClass<Object>> reducers;

  AppReducer() {
    this.reducers = new Map<String, ReducerClass<Object>>();
  }

  void putReducer(String tag, ReducerClass<Object> reducer) {
    this.reducers[tag] = reducer;
  }

  AppState call(AppState state, Action action) {
    Object substate = state.getState(action.meta);
    if (substate != null) {
      state.putState(
          action.meta, this.reducers[action.meta].call(substate, action));
    }
    return state;
  }
}

Store createStore() {
  final reducer = new AppReducer();
  final state = new AppState();
  final epicMiddleware = new EpicMiddleware(combineEpics<AppState>(<Epic<AppState>>[
    sessionEpic,
    deviceEpic,
    getDeviceEpic,
    postDeviceEpic,
    postUpgradeEpic,
    fetchUpgradeEpic,
    fetchUpgradesEpic,
    deleteUpgradeEpic,
    putUpgradeEpic,
  ]));

  reducer.putReducer(sessionkey, new SessionReducer());
  state.putState(sessionkey, new SessionState());
  reducer.putReducer(devicekey, new DeviceReducer());
  state.putState(devicekey, {
    "selected": new DeviceState(),
    "unregistered": new DeviceState(),
    "registered": new DeviceState(),
    "postunregistered": new DeviceState(),
  });
  reducer.putReducer(upgradekey, new UpgradeReducer());
  state.putState(upgradekey, {
    "fetchupgrades": new UpgradeState(),
    "test-waiting": new UpgradeState(),
    "test-failed": new UpgradeState(),
    "publish-waiting": new UpgradeState(),
    "published": new UpgradeState(),
    "fetchupgrade": new UpgradeState(),
    "postupgrade": new UpgradeState(),
    "putupgrade": new UpgradeState(),
    "deleteupgrade": new UpgradeState(),
    "select": new UpgradeState(),
  });
  return new Store(reducer, middleware: [epicMiddleware], initialState: state);
}
