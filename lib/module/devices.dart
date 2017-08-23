import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/model/device.dart';
import 'package:adminclient/store/device.dart';

class DevicesPage extends StatefulWidget {
  final String title;
  final Store store;
  DevicesPage({Key key, this.title, this.store}) : super(key: key);
  @override
  _DevicesPageState createState() => new _DevicesPageState();
}

class _Page {
  _Page({
    this.text,
    this.id,
  });
  final String text;
  final String id;
}

class _DevicesPageState extends State<DevicesPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _inputController = new TextEditingController();

  void _handleSubmitted(BuildContext context) {
    fetchUnregisteredDevices(widget.store, _inputController.text, 0);
  }

  void _saveSelectDevice(BuildContext context, Device device) {
    selectReigsteredDevice(widget.store, device);
  }

  TabController _controller;

  @override
  void initState() {
    Map<String, DeviceState> _states = widget.store.state.getState(devicekey);
    _controller = new TabController(vsync: this, length: _allPages.length);
    super.initState();
    DeviceState _unregisterState = _states["unregistered"];
    if (!_unregisterState.nomore && _unregisterState.data.length == 0) {
      fetchUnregisteredDevices(widget.store, "", _unregisterState.offset);
    }
    DeviceState _registerState = _states["registered"];
    if (!_registerState.nomore && _registerState.data.length == 0) {
      getReigsteredDevices(widget.store, _registerState.offset);
    }
  }

  final List<_Page> _allPages = <_Page>[
    new _Page(text: '未注册', id: "unregistered"),
    new _Page(text: '已注册', id: "registered"),
  ];
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
          title: new Text(widget.title),
          centerTitle: true,
          bottom: new TabBar(
            // 控件的选择和动画状态
            // 标签栏是否可以水平滚动
            controller: _controller,
            isScrollable: true,
            // 标签控件的列表
            tabs: _allPages
                .map((_Page page) => new Tab(text: page.text))
                .toList(),
          )),
      body: new Container(
          child: new Column(
        children: <Widget>[
          new Row(
            children: <Widget>[
              new Expanded(
                child: new TextField(
                  controller: _inputController,
                  decoration: new InputDecoration(hintText: "输入 PIN 码"),
                ),
              ),
              new RaisedButton(
                onPressed: () {
                  _handleSubmitted(context);
                },
                child: new Text("搜索"),
              ),
            ],
          ),
          new Expanded(
            child: new TabBarView(
                controller: _controller,
                children: _allPages.map((_Page page) {
                  return new ListView(
                    children: widget.store.state
                        .getState(devicekey)[page.id]
                        .data
                        .map((Device device) {
                      return new Container(
                        padding: const EdgeInsets.only(top: 0.0),
                        child: new ListTile(
                          leading: const Icon(Icons.mode_edit),
                          title: new Text("mac地址: " + device.mac),
                          subtitle: new Text(page.id == "unregistered"
                              ? "pin码: " + device.pin
                              : "地址：" + device.address),
                          onTap: () {
                            if (page.id == "registered") {
                              _saveSelectDevice(context, device);
                              Navigator.pushNamed(context, "/deviceDetail");
                            } else if (page.id == "unregistered") {
                              _saveSelectDevice(context, device);
                              Navigator.pushNamed(context, "/devicePost");
                            }
                          },
                        ),
                        height: 50.0,
                      );
                    }).toList(),
                  );
                }).toList()),
          ),
        ],
      )),
    );
  }
}
