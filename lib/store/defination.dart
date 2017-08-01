abstract class Action {
  String type;
  Object payload;
  bool error;
  String meta;
}


class AppState {
  Map<String, Object> states;
  AppState() {
    this.states = new Map<String, Object>();
  }

  Object getState(String tag) {
    return this.states[tag];
  }

  void putState(String tag, Object state) {
    this.states[tag] = state;
  }
}
