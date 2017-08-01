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

class _DevicesPageState extends State<DevicesPage> {
  final TextEditingController _inputController = new TextEditingController();

  void _handleSubmitted(BuildContext context) {
    fetchUnregisteredDevices(widget.store, _inputController.text, 0);
  }

  @override
  void initState() {
    super.initState();
    Map<String, DeviceState> _states = widget.store.state.getState(devicekey);
    DeviceState _state = _states["unregistered"];
    if (!_state.nomore &&
        _state.data.length == 0) {
      fetchUnregisteredDevices(widget.store, "", _state.offset);
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Map<String, DeviceState> _states = widget.store.state.getState(devicekey);
    DeviceState _state = _states["unregistered"];
    final ThemeData theme = Theme.of(context);
    final List<Widget> items = <Widget>[];
    if (_state.error == null) {
      items.addAll(_state.data.map((Device device) {
        return new Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: new ListTile(
            title: new Text(device.mac),
            subtitle: new Text(device.pin),
          ),
        );
      }).toList());
      if (_state.loading) {
        items.add(new Center(
          child: new CircularProgressIndicator(),
        ));
      }
    }

    return new Scaffold(
      appBar: new AppBar(title: new Text(widget.title)),
      body: new Column(
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
            child: new ListView(
              children: items,
            ),
          ),
        ],
      ),
    );
  }
}
