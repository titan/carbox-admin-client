import 'dart:async';
import 'package:flutter/services.dart';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/model/session.dart';

class SignInException implements Exception {
  String _message;

  SignInException(this._message);

  String toString() {
    return "Exception: $_message";
  }
}

Future signIn(String account, String password) {
  var client = createHttpClient();
  return client.post("${server}sessions", headers: {"content-type": "application/json"}, body: "{ \"account\": \"$account\", \"password\": \"$password\"}")
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    if (json.containsKey("state")) {
      throw new SignInException(
          "Error while signing in [StatusCode:${json["state"]}, Error:${json["msg"]}]");
    } else {
      var data = new Session();
      data.access_token = json["access-token"];
      data.refresh_token = json["refresh-token"];
      data.expires_at = new DateTime.fromMillisecondsSinceEpoch(
          new DateTime.now().millisecondsSinceEpoch +
              json["expires-in"] * 1000);
      return data;
    }
  }).whenComplete(client.close);
}
