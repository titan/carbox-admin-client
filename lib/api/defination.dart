import 'dart:async';
import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:adminclient/model/session.dart';

const server = "http://59.110.16.108:8888/";

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
    if (status == 401) {
      throw new TokenException(response.body);
    } else if (status == 403) {
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

Future checkSessionThenGet(Session session, http.Client client, String url) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client.get(url, headers: {"Token": session.access_token});
  } else {
    // try to refresh tokens
    return client
        .put("${server}sessions", body: {
          "access-token": session.access_token,
          "refresh-token": session.refresh_token
        })
        .then(checkStatus)
        .then(parseJsonMap)
        .then((Map json) {
          session.access_token = json["access_token"];
          session.refresh_token = json["refresh_token"];
          session.expires_at = new DateTime.fromMillisecondsSinceEpoch(
              new DateTime.now().millisecondsSinceEpoch +
                  json["expires_in"] * 1000);
          return client.get(url, headers: {"Token": session.access_token});
        });
  }
}

Future checkSessionThenPost(
    Session session, http.Client client, String url, String body) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client.post(url,
        headers: {
          "content-type": "application/json",
          "Token": session.access_token
        },
        body: body);
  } else {
    return client
        .put("${server}sessions", body: {
          "access-token": session.access_token,
          "refresh-token": session.refresh_token
        })
        .then(checkStatus)
        .then(parseJsonMap)
        .then((Map json) {
          session.access_token = json["access_token"];
          session.refresh_token = json["refresh_token"];
          session.expires_at = new DateTime.fromMillisecondsSinceEpoch(
              new DateTime.now().millisecondsSinceEpoch +
                  json["expires_in"] * 1000);
          return client.post(url,
              headers: {"Token": session.access_token}, body: body);
        });
  }
}

Future checkSessionThenPut(
    Session session, http.Client client, String url, String body) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client.put(url,
        headers: {"Token": session.access_token}, body: body);
  } else {
    // try to refresh tokens
    return client
        .put("${server}sessions", body: {
          "access-token": session.access_token,
          "refresh-token": session.refresh_token
        })
        .then(checkStatus)
        .then(parseJsonMap)
        .then((Map json) {
          session.access_token = json["access_token"];
          session.refresh_token = json["refresh_token"];
          session.expires_at = new DateTime.fromMillisecondsSinceEpoch(
              new DateTime.now().millisecondsSinceEpoch +
                  json["expires_in"] * 1000);
          return client.put(url,
              headers: {"Token": session.access_token}, body: body);
        });
  }
}

Future checkSessionThenOptions(
    Session session, http.Client client, String url) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client.get(url,
        headers: {"Token": session.access_token, "x-method": "options"});
  } else {
    // try to refresh tokens
    return client
        .put("${server}sessions", body: {
          "access-token": session.access_token,
          "refresh-token": session.refresh_token
        })
        .then(checkStatus)
        .then(parseJsonMap)
        .then((Map json) {
          session.access_token = json["access_token"];
          session.refresh_token = json["refresh_token"];
          session.expires_at = new DateTime.fromMillisecondsSinceEpoch(
              new DateTime.now().millisecondsSinceEpoch +
                  json["expires_in"] * 1000);
          return client.get(url,
              headers: {"Token": session.access_token, "x-method": "options"});
        });
  }
}

Future checkSessionThenDelete(Session session, http.Client client, String url) {
  if ((new DateTime.now().millisecondsSinceEpoch + 300000) <
      session.expires_at.millisecondsSinceEpoch) {
    return client.delete(url, headers: {"Token": session.access_token});
  } else {
    // try to refresh tokens
    return client
        .put("${server}sessions", body: {
          "access-token": session.access_token,
          "refresh-token": session.refresh_token
        })
        .then(checkStatus)
        .then(parseJsonMap)
        .then((Map json) {
          session.access_token = json["access_token"];
          session.refresh_token = json["refresh_token"];
          session.expires_at = new DateTime.fromMillisecondsSinceEpoch(
              new DateTime.now().millisecondsSinceEpoch +
                  json["expires_in"] * 1000);
          return client.delete(url, headers: {"Token": session.access_token});
        });
  }
}
