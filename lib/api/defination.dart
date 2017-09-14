import 'dart:async';
import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:adminclient/model/session.dart';

const server = "http://boxota.fengchaohuzhu.com:8888/";

class TokenException implements Exception {
  String _message;

  TokenException(this._message);

  String toString() {
    return "TokenException: ${_message}";
  }
}

http.Response checkStatus(http.Response response) {
  final status = response.statusCode;
  if (status > 199 && status < 300) {
    return response;
  } else {
    if (status == 401 || status == 403) {
      throw new TokenException(response.body);
    } else {
      throw new http.ClientException(response.body);
    }
  }
}

Map parseJsonMap(http.Response response) {
  return JSON.decode(response.body);
}

List parseJsonList(http.Response response) {
  return JSON.decode(response.body);
}

class CollectionResponse<T> {
  List<T> data;
  int total;
  int offset;
}

typedef Future TokenCallback(Session session);

Future _refreshToken(Session session, http.Client client, TokenCallback cb) {
  if (session.access_token == null || session.refresh_token == null) {
    throw new TokenException("Invalid Token");
  }
  return client
      .put(
        "${server}sessions",
        body: {
          "access-token": session.access_token,
          "refresh-token": session.refresh_token,
        },
      )
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
        session.access_token = json["access-token"];
        session.refresh_token = json["refresh-token"];
        session.expires_at = new DateTime.fromMillisecondsSinceEpoch(
            new DateTime.now().millisecondsSinceEpoch +
                (json["expires-in"] ?? 0) * 1000);
        return cb(session);
      });
}

Future checkSessionThenGet(Session session, http.Client client, String url) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client
        .get(url, headers: {"Token": session.access_token})
        .then(checkStatus)
        .catchError((error) {
          if (error is TokenException) {
            return _refreshToken(session, client, (_session) {
              return client.get(url,
                  headers: {"Token": _session.access_token}).then(checkStatus);
            });
          } else {
            throw error;
          }
        });
  } else {
    return _refreshToken(session, client, (_session) {
      return client.get(url, headers: {"Token": _session.access_token});
    });
  }
}

Future checkSessionThenPost(
    Session session, http.Client client, String url, Map<String, String> body) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client
        .post(url, headers: {"Token": session.access_token}, body: body)
        .then(checkStatus)
        .catchError((error) {
      if (error is TokenException) {
        return _refreshToken(session, client, (_session) {
          return client
              .post(url, headers: {"Token": session.access_token}, body: body)
              .then(checkStatus);
        });
      } else {
        throw error;
      }
    });
  } else {
    return _refreshToken(session, client, (_session) {
      return client
          .post(url, headers: {"Token": session.access_token}, body: body)
          .then(checkStatus);
    });
  }
}

Future checkSessionThenPut(
    Session session, http.Client client, String url, Map<String, String> body) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client
        .put(url, headers: {"Token": session.access_token}, body: body)
        .then(checkStatus)
        .catchError((error) {
      if (error is TokenException) {
        return _refreshToken(session, client, (_session) {
          return client
              .put(url, headers: {"Token": session.access_token}, body: body)
              .then(checkStatus);
        });
      } else {
        throw error;
      }
    });
  } else {
    return _refreshToken(session, client, (_session) {
      return client
          .put(url, headers: {"Token": session.access_token}, body: body)
          .then(checkStatus);
    });
  }
}

Future checkSessionThenOptions(
    Session session, http.Client client, String url) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client
        .get(url, headers: {
          "Token": session.access_token,
          "x-method": "options",
        })
        .then(checkStatus)
        .catchError((error) {
          if (error is TokenException) {
            return _refreshToken(session, client, (_session) {
              return client.get(url, headers: {
                "Token": _session.access_token,
                "x-method": "options",
              }).then(checkStatus);
            });
          } else {
            throw error;
          }
        });
  } else {
    return _refreshToken(session, client, (_session) {
      return client.get(url, headers: {
        "Token": _session.access_token,
        "x-method": "options",
      }).then(checkStatus);
    });
  }
}

Future checkSessionThenDelete(Session session, http.Client client, String url) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client
        .delete(url, headers: {"Token": session.access_token})
        .then(checkStatus)
        .catchError((error) {
          if (error is TokenException) {
            return _refreshToken(session, client, (_session) {
              return client.delete(url,
                  headers: {"Token": session.access_token}).then(checkStatus);
            });
          } else {
            throw error;
          }
        });
  } else {
    return _refreshToken(session, client, (_session) {
      return client.delete(url,
          headers: {"Token": session.access_token}).then(checkStatus);
    });
  }
}
