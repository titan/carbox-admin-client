import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/store/store.dart';
import 'package:adminclient/module/devices.dart';
import 'package:adminclient/module/home.dart';
import 'package:adminclient/module/launcher.dart';
import 'package:adminclient/module/signin.dart';
import 'package:adminclient/module/deviceDetail.dart';
import 'package:adminclient/module/devicePost.dart';
import 'package:adminclient/module/upgrades.dart';
import 'package:adminclient/module/upgradePost.dart';
import 'package:adminclient/module/upgradeDetail.dart';

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
        '/home': (BuildContext context) =>
            new HomePage(title: '主页', store: store),
        '/signin': (BuildContext context) =>
            new SignInPage(title: '用户登录', store: store),
        '/devices': (BuildContext context) =>
            new DevicesPage(title: '设备管理', store: store),
        '/deviceDetail': (BuildContext context) =>
            new DeviceDetailPage(title: '设备信息', store: store),
        '/devicePost': (BuildContext context) =>
            new DevicePostPage(title: '设备注册', store: store),
        '/upgrades': (BuildContext context) =>
            new UpgradesPage(title: '升级管理', store: store),
        '/upgradePost': (BuildContext context) =>
            new UpgradePostPage(title: '信息提交', store: store),
        '/upgradeDetail': (BuildContext context) =>
            new UpgradeDetailPage(title: '升级详情', store: store),
      },
    );
  }
}
