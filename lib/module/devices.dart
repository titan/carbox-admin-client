import 'dart:async';
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

List<_Page> _pages = <_Page>[
  new _Page(text: '未注册', id: "unregistered"),
  new _Page(text: '已注册', id: "registered"),
];

class _DevicesPageState extends State<DevicesPage>
    with SingleTickerProviderStateMixin {
  _Page _selectedPage = _pages[0];
  TabController _controller;
  Map<String, DeviceState> _deviceStates;
  final ScrollController _scrollController = new ScrollController();
  StreamSubscription _subscription;

  final TextEditingController _inputController = new TextEditingController();

  void _handleSubmitted() {
    fetchUnregisteredDevices(widget.store, _inputController.text, 0);
  }

  void _handleTabSelection() {
    setState(() {
      _selectedPage = _pages[_controller.index];
      DeviceState _state = _deviceStates[_selectedPage.id];
      if (!_state.nomore && _state.data.length == 0) {
        if (_selectedPage.id == "unregistered") {
          fetchUnregisteredDevices(
              widget.store, _inputController.text, _state.offset);
        } else {
          fetchRegisteredDevices(widget.store, _state.offset);
        }
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0 && notification is OverscrollNotification) {
      if (notification.overscroll > 0) {
        // got to the end of scrollable
        UpgradeState _state = _upgradeStates[_selectedPage.id];
        if (!_state.nomore) {
          if (_selectedPage.id == "unregistered") {
            fetchUnregisteredDevices(
                widget.store, _inputController.text, _state.offset);
          } else {
            fetchRegisteredDevices(widget.store, _state.offset);
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _deviceStates = widget.store.state.getState(devicekey);
    _controller = new TabController(
      vsync: this,
      length: _pages.length,
    );
    _controller.addListener(_handleTabSelection);
    DeviceState _state = _deviceStates[_selectedPage.id];
    if (!_state.nomore && _state.data.length == 0) {
      if (_selectedPage.id == "unregistered") {
        fetchUnregisteredDevices(
            widget.store, _inputController.text, _state.offset);
      } else {
        fetchRegisteredDevices(widget.store, _state.offset);
      }
    }
    _subscription = widget.store.onChange.listen((state) {
      DeviceState _state = _deviceStates[_selectedPage.id];
      if (!_state.nomore && _state.data.length == 0 && !_state.loading) {
        if (_selectedPage.id == "unregistered") {
          fetchUnregisteredDevices(
              widget.store, _inputController.text, _state.offset);
        } else {
          fetchRegisteredDevices(widget.store, _state.offset);
        }
      } else {
        setState(() {}); // just notify interface to refresh
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _subscription.cancel();
    super.dispose();
  }

  Widget buildItem(final ThemeData theme, final _Page page,
      final DeviceState state, final Device device) {
    return new ListTile(
      title: new Text("mac地址: " + device.mac),
      subtitle: new Text(page.id == "unregistered"
          ? "pin码: " + device.pin
          : "地址：" + device.address),
      onTap: () {
        if (page.id == "registered") {
          selectRegisteredDevice(widget.store, device);
          Navigator.pushNamed(context, "/device");
        } else if (page.id == "unregistered") {
          selectUnregisteredDevice(widget.store, device);
          Navigator.pushNamed(context, "/device");
        }
      },
    );
  }

  List<Widget> fillListView(
      final ThemeData theme, final _Page page, final DeviceState state) {
    List<Widget> items =
        state.data.map((x) => buildItem(theme, page, state, x)).toList();
    if (state.loading) {
      items.add(new Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CircularProgressIndicator(),
          new Text("加载中..."),
        ],
      ));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        centerTitle: true,
        bottom: new TabBar(
          controller: _controller,
          isScrollable: true,
          tabs: _pages.map((_Page page) => new Tab(text: page.text)).toList(),
        ),
      ),
      body: new TabBarView(
          controller: _controller,
          children: _pages.map((_Page _page) {
            DeviceState _state = _deviceStates[_page.id];
            return _page.id == "unregistered"
                ? (_state.error != null
                    ? new Center(child: new Text(_state.error.toString()))
                    : new Column(
                        children: [
                          new Row(
                            children: <Widget>[
                              new Expanded(
                                child: new TextField(
                                  controller: _inputController,
                                  decoration: new InputDecoration(
                                    hintText: "输入 PIN 码",
                                  ),
                                ),
                              ),
                              new RaisedButton(
                                onPressed: () {
                                  _handleSubmitted();
                                },
                                child: new Text("搜索"),
                              ),
                            ],
                          ),
                          new Expanded(
                            child: new NotificationListener<ScrollNotification>(
                              onNotification: _handleScrollNotification,
                              child: new ListView(
                                children: fillListView(theme, _page, _state),
                              ),
                            ),
                          ),
                        ],
                      ))
                : (_state.error != null
                    ? new Center(child: new Text(_state.error.toString()))
                    : new NotificationListener<ScrollNotification>(
                        onNotification: _handleScrollNotification,
                        child: new ListView(
                          children: fillListView(theme, _page, _state),
                        ),
                      ));
          }).toList()),
    );
  }
}
