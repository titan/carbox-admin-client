import 'dart:async';
import "dart:convert";
import 'package:flutter/services.dart';
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

Future<CollectionResponse> fetchgrades(
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
      upgrade.constraint = d["constraint"];
      collections.data.add(upgrade);
    }
    return collections;
  }).whenComplete(client.close);
}

Future<CollectionResponse> fetchgrade({Session session, int id}) {
  var client = createHttpClient();
  return checkSessionThenOptions(session, client, "${server}upgrades/${id}")
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
      upgrade.constraint = d["constraint"];
      collections.data.add(upgrade);
    }
    return collections;
  }).whenComplete(client.close);
}

Future postUpgrade({
  Session session,
  int state,
  String url,
  String type,
  int systemBoard,
  int lockBoard,
  int version,
  int constraint,
}) {
  var client = createHttpClient();
  var body = {
    "system-board": systemBoard,
    "lock-board": lockBoard,
    "url": url,
    "type": type,
    "version": version,
    "state": state,
    "constraint": constraint,
  };
  return checkSessionThenPost(
          session, client, "${server}upgrades", JSON.encode(body))
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    var data = json;
    return data;
  }).whenComplete(client.close);
}

Future putUpgrade({
  Session session,
  int state,
  String url,
  String type,
  int systemBoard,
  int lockBoard,
  int id,
  int version,
  int constraint,
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
    "constraint": constraint,
  };
  return checkSessionThenPut(
          session, client, "${server}upgrades/${id}", JSON.encode(body))
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    var data = json;
    return data;
  }).whenComplete(client.close);
}

Future deleteUpgrade({
  Session session,
  int id,
}) {
  var client = createHttpClient();
  return checkSessionThenDelete(session, client, "${server}upgrades/${id}")
      .then(checkStatus)
      // .then(parseJsonMap)
      .then((data) {
    // var data = json;
    // return data;
    return;
  }).whenComplete(client.close);
}
