import 'dart:async';
import "dart:convert";
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/model/upgrade.dart';
import 'package:adminclient/model/session.dart';

class PostException implements Exception {
  String _message;

  PostException(this._message);

  String toString() {
    return "Exception: $_message";
  }
}

Future<CollectionResponse> fetchUpgrades(
    {Session session, int state, int offset = 0, int limit = 20}) {
  var client = createHttpClient();
  return checkSessionThenOptions(session, client,
          "${server}upgrades?state=${state}offset=${offset}&limit=${limit}")
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    CollectionResponse<Upgrade> collections = new CollectionResponse<Upgrade>();
    collections.total = json["total"];
    collections.offset = json["offset"];
    collections.data = new List<Upgrade>();
    for (var d in json["data"]) {
      Upgrade upgrade = new Upgrade();
      upgrade.state = d["state"];
      upgrade.systemBoard = d["system-board"];
      upgrade.url = d["url"];
      upgrade.lockBoard = d["lock-board"];
      upgrade.version = d["version"];
      upgrade.id = d["id"];
      upgrade.type = d["type"];
      collections.data.add(upgrade);
    }
    return collections;
  }).whenComplete(client.close);
}

Future<CollectionResponse> fetchUpgrade({Session session, int id}) {
  var client = createHttpClient();
  return checkSessionThenOptions(session, client, "${server}upgrades/${id}")
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    Upgrade upgrade = new Upgrade();
    upgrade.state = json["state"];
    upgrade.systemBoard = json["system-board"];
    upgrade.url = json["url"];
    upgrade.lockBoard = json["lock-board"];
    upgrade.version = json["version"];
    upgrade.id = json["id"];
    upgrade.type = json["type"];
    return upgrade;
  }).whenComplete(client.close);
}

Future createUpgrade({
  Session session,
  int state,
  String url,
  String type,
  int systemBoard,
  int lockBoard,
  int version,
}) {
  var client = createHttpClient();
  var body = {
    "system-board": systemBoard,
    "lock-board": lockBoard,
    "url": url,
    "type": type,
    "version": version,
    "state": state,
  };
  return checkSessionThenPost(
          session, client, "${server}upgrades", JSON.encode(body))
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    Upgrade upgrade = new Upgrade();
    upgrade.state = json["state"];
    upgrade.systemBoard = json["system-board"];
    upgrade.url = json["url"];
    upgrade.lockBoard = json["lock-board"];
    upgrade.version = json["version"];
    upgrade.id = json["id"];
    upgrade.type = json["type"];
    return upgrade;
  }).whenComplete(client.close);
}

Future modifyUpgrade({
  Session session,
  int state,
  String url,
  String type,
  int systemBoard,
  int lockBoard,
  int id,
  int version,
}) {
  var client = createHttpClient();
  var body = {
    "system-board": systemBoard,
    "lock-board": lockBoard,
    "url": url,
    "type": type,
    "id": id,
    "version": version,
    "state": state,
  };
  return checkSessionThenPut(
          session, client, "${server}upgrades/${id}", JSON.encode(body))
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    Upgrade upgrade = new Upgrade();
    upgrade.systemBoard = json["system-board"];
    upgrade.url = json["url"];
    upgrade.lockBoard = json["lock-boadr"];
    upgrade.version = json["version"];
    upgrade.id = json["id"];
    upgrade.type = json["type"];
    return upgrade;
  }).whenComplete(client.close);
}

Future deleteUpgrade({
  Session session,
  int id,
}) {
  var client = createHttpClient();
  return checkSessionThenDelete(session, client, "${server}upgrades/${id}")
      .then(checkStatus)
      .then((http.Response response) {
    return true;
  }).whenComplete(client.close);
}
