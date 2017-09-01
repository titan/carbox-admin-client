import 'dart:async';
import 'package:adminclient/api/session.dart' as api;
import 'package:adminclient/model/session.dart';
import 'package:adminclient/store/defination.dart';
import 'package:redux/redux.dart';
import 'package:redux_epics/redux_epics.dart';

const String sessionkey = 'session';

class SessionState {
  Session session;
  bool loading = false;
  Exception error;
}

class SessionActionPayload {
  Session session;
  String account;
  String password;
  Exception error;
  SessionActionPayload({
    this.account,
    this.password,
    this.session,
    this.error,
  });
}

class SessionAction implements Action {
  String type;
  SessionActionPayload payload;
  bool error;
  String meta;
  SessionAction({
    this.type,
    this.payload,
    this.error = false,
    this.meta = sessionkey,
  });
}

class SessionReducer extends ReducerClass<SessionState> {
  SessionState call(SessionState state, SessionAction action) {
    switch (action.type) {
      case 'SIGNIN_REQUEST':
        state.loading = true;
        return state;
      case 'SIGNIN_SUCCESS':
        state.loading = false;
        state.session = action.payload.session;
        return state;
      case 'SIGNIN_FAILED':
        state.loading = false;
        state.error = action.payload.error;
        state.session = null;
        return state;
      default:
        return state;
    }
  }
}

Stream<Action> sessionEpic(Stream<Action> actions, EpicStore<AppState> store) {
  return actions
      .where((action) =>
          action is SessionAction && action.type == 'SIGNIN_REQUEST')
      .map((action) => (action as SessionAction).payload)
      .asyncMap((payload) => api
              .signIn(payload.account, payload.password)
              .then((Session session) => new SessionAction(
                    type: 'SIGNIN_SUCCESS',
                    payload: new SessionActionPayload(
                      session: session,
                      account: payload.account,
                    ),
                    error: false,
                  ))
              .catchError((error) {
            print(error);
            if (error is Error) {
              print(error.stackTrace);
            }
            return new SessionAction(
              type: 'SIGNIN_FAILED',
              payload: new SessionActionPayload(
                error: (error is Exception)
                    ? error
                    : new Exception("${error}${error.stackTrace}"),
              ),
              error: true,
            );
          }));
}

void signIn(Store store, String account, String password) {
  store.dispatch(new SessionAction(
    type: 'SIGNIN_REQUEST',
    payload: new SessionActionPayload(
      account: account,
      password: password,
    ),
  ));
}

void reportInvalidToken(Store store, Exception error) {
  store.dispatch(new SessionAction(
    type: 'SIGNIN_FAILED',
    payload: new SessionActionPayload(error: error),
    error: true,
    meta: sessionkey,
  ));
}
