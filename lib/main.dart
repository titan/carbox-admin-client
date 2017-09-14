import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/store/store.dart';
import 'package:adminclient/module/device.dart';
import 'package:adminclient/module/devices.dart';
import 'package:adminclient/module/home.dart';
import 'package:adminclient/module/launcher.dart';
import 'package:adminclient/module/signin.dart';
import 'package:adminclient/module/upgrade.dart';
import 'package:adminclient/module/upgrades.dart';

void main() {
  runApp(new AppWidget());
}

class AppWidget extends StatefulWidget {
  @override
  _AppState createState() => new _AppState();
}

class _AppState extends State<AppWidget> {
  Store store = createStore();

  @override
  void initState() {
    super.initState();
    store.onChange.listen((_) {
      setState(() {});
    });
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Admin Client',
      theme: new ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting
        // the app, try changing the primarySwatch below to Colors.green
        // and press "r" in the console where you ran "flutter run".
        // We call this a "hot reload". Notice that the counter didn't
        // reset back to zero -- the application is not restarted.
        primarySwatch: Colors.blue,
      ),
      //home: new LauncherPage(title: 'Launcher', store: store),
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => new LauncherPage(store: store),
        '/devices': (BuildContext context) =>
            new DevicesPage(title: '设备管理', store: store),
        '/device': (BuildContext context) =>
            new DevicePage(title: '设备信息', store: store),
        '/upgrades': (BuildContext context) =>
            new UpgradesPage(title: '升级管理', store: store),
        '/upgrade': (BuildContext context) =>
            new UpgradePage(title: '升级详情', store: store),
      },
    );
  }
}
