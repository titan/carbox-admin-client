import 'dart:async';
import "dart:convert";
import 'package:flutter/services.dart';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/model/device.dart';
import 'package:adminclient/model/session.dart';

class PostException implements Exception {
  String _message;

  PostException(this._message);

  String toString() {
    return "Exception: $_message";
  }
}

Future<CollectionResponse> fetchUnregisteredDevices(
    {Session session, String pin = "", int offset = 0, int limit = 20}) {
  var client = createHttpClient();
  return checkSessionThenOptions(session, client,
          "${server}devices?query=${pin}&offset=${offset}&limit=${limit}")
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    CollectionResponse<Device> collections = new CollectionResponse<Device>();
    collections.total = json["total"];
    collections.offset = json["offset"];
    collections.data = new List<Device>();
    for (var d in json["data"]) {
      Device device = new Device();
      device.mac = d["mac"];
      device.pin = d["pin"];
      /*
      device.address = d["address"];
      device.androidBoard = d["android-board"];
      device.lockBoard = d["lock-board"];
      device.lockAmount = d["lock-amount"];
      device.wireless = d["wireless"];
      device.antenna = d["antenna"];
      device.cardReader = d["cardReader"];
      device.speaker = d["speaker"];
      */
      collections.data.add(device);
    }
    return collections;
  }).whenComplete(client.close);
}

Future<CollectionResponse> fetchRegisteredDevices({
  Session session,
  int offset = 0,
  int limit = 10,
}) {
  var client = createHttpClient();
  return checkSessionThenGet(
          session, client, "${server}devices?offset=${offset}&limit=${limit}")
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    CollectionResponse<Device> collections = new CollectionResponse<Device>();
    collections.total = json["total"];
    collections.offset = json["offset"];
    collections.data = new List<Device>();
    for (var d in json["data"]) {
      Device device = new Device();
      device.mac = d["mac"];
      device.simNo = d["sim-no"];
      device.speaker = d["speaker"];
      device.antenna = d["antenna"];
      device.address = d["address"];
      device.wireless = d["wireless"];
      device.lockBoard = d["lock-board"];
      device.cardReader = d["card-reader"];
      device.lockAmount = d["lock-amount"];
      device.systemBoard = d["system-board"];
      device.routerBoard = d["router-board"];
      collections.data.add(device);
    }
    return collections;
  }).whenComplete(client.close);
}

Future postUnreigsteredDevice(
    {Session session,
    String mac,
    String pin,
    String address,
    int systemBoard,
    int lockBoard,
    int lockAmount,
    int wireless,
    int antenna,
    int cardReader,
    int speaker,
    int simNo,
    int routerBoard}) {
  var client = createHttpClient();
  var body = {
    "router-board": routerBoard,
    "antenna": antenna,
    "mac": "$mac",
    "system-board": systemBoard,
    "lock-amount": lockAmount,
    "wireless": wireless,
    "speaker": speaker,
    "sim-no": simNo,
    "address": "$address",
    "lock-board": lockBoard,
    "card-reader": cardReader
  };
  return checkSessionThenPost(
          session, client, "${server}devices", JSON.encode(body))
      .then(checkStatus)
      .then(parseJsonMap)
      .then((Map json) {
    var data = json;
    return data;
  }).whenComplete(client.close);
}
