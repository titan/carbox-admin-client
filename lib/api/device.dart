import 'dart:async';
import "dart:convert";
import 'package:flutter/services.dart';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/model/device.dart';
import 'package:adminclient/model/session.dart';

Future<CollectionResponse> fetchUnregisteredDevices({
  Session session,
  String pin = "",
  int offset = 0,
  int limit = 20,
}) {
  var client = createHttpClient();
  return checkSessionThenOptions(session, client,
          "${server}devices?query=${pin}&offset=${offset}&limit=${limit}")
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

Future registerDevice({
  Session session,
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
  int routerBoard,
}) {
  var client = createHttpClient();
  var body = {
    "pin": pin,
    "router-board": routerBoard.toString(),
    "antenna": antenna.toString(),
    "mac": mac,
    "system-board": systemBoard.toString(),
    "lock-amount": lockAmount.toString(),
    "wireless": wireless.toString(),
    "speaker": speaker.toString(),
    "sim-no": simNo.toString(),
    "address": address,
    "lock-board": lockBoard.toString(),
    "card-reader": cardReader.toString(),
  };
  return checkSessionThenPost(session, client, "${server}devices", body)
      .then(parseJsonMap)
      .then((Map json) {
    Device device = new Device();
    device.mac = json["mac"];
    device.simNo = json["sim-no"];
    device.speaker = json["speaker"];
    device.antenna = json["antenna"];
    device.address = json["address"];
    device.wireless = json["wireless"];
    device.lockBoard = json["lock-board"];
    device.cardReader = json["card-reader"];
    device.lockAmount = json["lock-amount"];
    device.systemBoard = json["system-board"];
    device.routerBoard = json["router-board"];
    return device;
  }).whenComplete(client.close);
}

Future modifyDevice({
  Session session,
  String mac,
  String address,
  int systemBoard,
  int lockBoard,
  int lockAmount,
  int wireless,
  int antenna,
  int cardReader,
  int speaker,
  int simNo,
  int routerBoard,
}) {
  var client = createHttpClient();
  var body = {
    "router-board": routerBoard.toString(),
    "antenna": antenna.toString(),
    "mac": mac,
    "system-board": systemBoard.toString(),
    "lock-amount": lockAmount.toString(),
    "wireless": wireless.toString(),
    "speaker": speaker.toString(),
    "sim-no": simNo.toString(),
    "address": address,
    "lock-board": lockBoard.toString(),
    "card-reader": cardReader.toString(),
  };
  return checkSessionThenPut(session, client, "${server}devices/${mac}", body)
      .then(parseJsonMap)
      .then((Map json) {
    Device device = new Device();
    device.mac = json["mac"];
    device.simNo = json["sim-no"];
    device.speaker = json["speaker"];
    device.antenna = json["antenna"];
    device.address = json["address"];
    device.wireless = json["wireless"];
    device.lockBoard = json["lock-board"];
    device.cardReader = json["card-reader"];
    device.lockAmount = json["lock-amount"];
    device.systemBoard = json["system-board"];
    device.routerBoard = json["router-board"];
    return device;
  }).whenComplete(client.close);
}
