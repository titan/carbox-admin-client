import 'package:adminclient/store/defination.dart';
import 'package:adminclient/store/session.dart';
import 'package:adminclient/store/device.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

class AppReducer extends Reducer<AppState, Action> {
  Map<String, Reducer<Object, Action>> reducers;

  AppReducer() {
    this.reducers = new Map<String, Reducer<Object, Action>>();
  }

  void putReducer(String tag, Reducer<Object, Action> reducer) {
    this.reducers[tag] = reducer;
  }

  AppState reduce(AppState state, Action action) {
    Object substate = state.getState(action.meta);
    if (substate != null) {
      state.putState(action.meta, this.reducers[action.meta].reduce(substate, action));
    }
    return state;
  }
}

Store createStore() {
  final reducer = new AppReducer();
  final state = new AppState();
  final epicMiddleware = new EpicMiddleware(new CombinedEpic<AppState, Action>([
    new SessionEpic(),
    new DeviceEpic(),
  ]));

  reducer.putReducer(sessionkey, new SessionReducer());
  state.putState(sessionkey, new SessionState());
  reducer.putReducer(devicekey, new DeviceReducer());
  state.putState(devicekey, {"selected": null, "unregistered": new DeviceState(), "registered": new DeviceState(), });
  return new Store(reducer, middleware: [epicMiddleware], initialState: state);
}
