import 'dart:async';
import 'package:flutter/services.dart';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/model/device.dart';
import 'package:adminclient/model/session.dart';

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
