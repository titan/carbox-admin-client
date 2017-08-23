import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/store/device.dart';
import 'package:adminclient/model/device.dart';

class DevicePostPage extends StatefulWidget {
  final String title;
  final Store store;

  DevicePostPage({Key key, this.title, this.store}) : super(key: key);

  @override
  _DevicePostPageState createState() => new _DevicePostPageState();
}

Device _selected;

int _systemBoard = 1,
    _lockAmount = 18,
    _lockBoard = 1,
    _wireless = 2,
    _antenna = 1,
    _cardReader = 1,
    _speaker = 1,
    _routerBoard = 0;

String _address, _simNo;

class _DevicePostPageState extends State<DevicePostPage> {
  @override
  void initState() {
    super.initState();
    Map<String, DeviceState> _states = widget.store.state.getState(devicekey);
    DeviceState selected = _states["selected"];
    _selected = selected.selected;
    widget.store.onChange.listen((state) {
      var pop = widget.store.state
                  .getState(devicekey)["postunregistered"]
                  .postend ==
              true
          ? widget.store.state.getState(devicekey)["postunregistered"].error !=
                  null
              ? _showMessage(
                  widget.store.state
                      .getState(devicekey)["postunregistered"]
                      .error
                      .toString(),
                  false)
              : _showMessage("提交成功", true)
          : null;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  final TextEditingController _input1Controller = new TextEditingController();
  final TextEditingController _input2Controller = new TextEditingController();
  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  bool _autovalidate = false;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  void _handleSubmitted(BuildContext context) {
    Device device = new Device();
    device.address = _address;
    device.mac = _selected.mac;
    device.pin = _selected.pin;
    device.systemBoard = _systemBoard;
    device.lockBoard = _lockBoard;
    device.lockAmount = _lockAmount;
    device.wireless = _wireless;
    device.antenna = _antenna;
    device.cardReader = _cardReader;
    device.speaker = _speaker;
    device.simNo = int.parse(_simNo);
    device.routerBoard = _routerBoard;
    postUnreigsteredDevices(widget.store, device);
  }

  String _system1Board = "A20主板",
      _lock1Amount = "18",
      _lock1Board = "20路中立锁控板",
      _wireless1 = "3G",
      _antenna1 = "棒状天线",
      _card1Reader = "ID/IC USB读卡器",
      _speaker1 = "插针式立体声音箱",
      _router1Board = "无";
  void _showMessage(text, state) {
    showDialog<Null>(
        context: context,
        child: new AlertDialog(
            // content: new Text('You tapped the floating action button.'),
            content: new Text(text),
            actions: <Widget>[
              new FlatButton(
                  onPressed: () {
                    if (state == true) {
                      Navigator.pushNamed(context, "/deviceDetail");
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('确认'))
            ]));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('信息提交'),
        centerTitle: true,
      ),
      body: new Form(
        key: _formKey,
        autovalidate: _autovalidate,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            new ListTile(
              title: new Text("mac地址",
                  style: new TextStyle(
                    fontSize: 18.0,
                  )),
              trailing:
                  new Text(_selected.mac, style: new TextStyle(fontSize: 18.0)),
            ),
            new ListTile(
              title: new Text("pin码",
                  style: new TextStyle(
                    fontSize: 18.0,
                  )),
              trailing:
                  new Text(_selected.pin, style: new TextStyle(fontSize: 18.0)),
            ),
            new ListTile(
                title: new Text("号码",
                    style: new TextStyle(
                      fontSize: 16.0,
                    )),
                trailing: new Container(
                  child: new TextField(
                    controller: _input1Controller,
                    decoration: new InputDecoration(hintText: "请输入手机卡号"),
                    maxLines: 1,
                    onChanged: (String value) {
                      _simNo = value;
                    },
                  ),
                  width: 200.0,
                )),
            new ListTile(
                title: new Text("地址",
                    style: new TextStyle(
                      fontSize: 16.0,
                    )),
                trailing: new Container(
                  child: new TextField(
                    controller: _input2Controller,
                    decoration: new InputDecoration(hintText: "请输入地址"),
                    maxLines: 1,
                    onChanged: (String value) {
                      _address = value;
                    },
                  ),
                  width: 200.0,
                )),
            new ListTile(
              title: const Text('主板型号'),
              trailing: new DropdownButton<String>(
                value: _system1Board,
                onChanged: (String newValue) {
                  setState(() {
                    _system1Board = newValue;
                    if (newValue == "无") {
                      _systemBoard = 0;
                    } else {
                      _systemBoard = 1;
                    }
                  });
                },
                items: <String>['无', 'A20主板'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
            new ListTile(
              title: const Text('锁控型号'),
              trailing: new DropdownButton<String>(
                value: _lock1Board,
                onChanged: (String newValue) {
                  setState(() {
                    _lock1Board = newValue;
                    if (newValue == "无") {
                      _lockBoard = 0;
                    } else {
                      _lockBoard = 1;
                    }
                  });
                },
                items: <String>['无', '20路中立锁控板'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
            new ListTile(
              title: const Text('锁总个数'),
              trailing: new DropdownButton<String>(
                value: _lock1Amount,
                onChanged: (String newValue) {
                  setState(() {
                    _lock1Amount = newValue;
                    _lockAmount = int.parse(newValue);
                  });
                },
                items: <String>['18'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
            new ListTile(
              title: const Text('连接方式'),
              trailing: new DropdownButton<String>(
                value: _wireless1,
                onChanged: (String newValue) {
                  setState(() {
                    _wireless1 = newValue;
                    if (newValue == "无") {
                      _wireless = 0;
                    } else if (newValue == "3G") {
                      _wireless = 2;
                    } else if (newValue == "4G") {
                      _wireless = 3;
                    } else {
                      _wireless = 1;
                    }
                  });
                },
                items: <String>['无', '3G', '4G', 'WIFI'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
            new ListTile(
              title: const Text('天线类型'),
              trailing: new DropdownButton<String>(
                value: _antenna1,
                onChanged: (String newValue) {
                  setState(() {
                    _antenna1 = newValue;
                    if (newValue == "无") {
                      _antenna = 0;
                    } else if (newValue == "吸盘天线") {
                      _antenna = 2;
                    } else {
                      _antenna = 1;
                    }
                  });
                },
                items: <String>['无', '棒状天线', '吸盘天线'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
            new ListTile(
              title: const Text('读卡器型号'),
              trailing: new DropdownButton<String>(
                value: _card1Reader,
                onChanged: (String newValue) {
                  setState(() {
                    _card1Reader = newValue;
                    if (newValue == "无") {
                      _cardReader = 0;
                    } else {
                      _cardReader = 1;
                    }
                  });
                },
                items: <String>['无', 'ID/IC USB读卡器'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
            new ListTile(
              title: const Text('扬声器型号'),
              trailing: new DropdownButton<String>(
                value: _speaker1,
                onChanged: (String newValue) {
                  setState(() {
                    _speaker1 = newValue;
                    if (newValue == "无") {
                      _speaker = 0;
                    } else {
                      _speaker = 1;
                    }
                  });
                },
                items: <String>['无', '插针式立体声音箱'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
            new ListTile(
              title: const Text('路由板型号'),
              trailing: new DropdownButton<String>(
                value: _router1Board,
                onChanged: (String newValue) {
                  setState(() {
                    _router1Board = newValue;
                    if (newValue == "无") {
                      _routerBoard = 0;
                    } else {
                      _routerBoard = 1;
                    }
                  });
                },
                items: <String>['无', 'xxx'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                }).toList(),
              ),
            ),
            // new Container(
            //   padding: const EdgeInsets.symmetric(vertical: 10.0),
            //   child: new FlatButton(
            //     color: Colors.blue[500],
            //     textColor: Colors.white,
            //     child: new Text(
            //       '提交',
            //       style: new TextStyle(fontSize: 18.0),
            //     ),
            //     onPressed: () {
            //       _handleSubmitted(context);
            //     },
            //   ),
            // ),
            new Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: new FlatButton(
                color: widget.store.state
                        .getState(devicekey)["postunregistered"]
                        .loading
                    ? null
                    : Colors.blue[500],
                textColor: Colors.white,
                child: widget.store.state
                        .getState(devicekey)["postunregistered"]
                        .loading
                    ? new Center(
                        child: new CircularProgressIndicator(),
                      )
                    : new Text(
                        '提交',
                        style: new TextStyle(fontSize: 18.0),
                      ),
                onPressed: () {
                  _handleSubmitted(context);
                },
              ),
            ),
            new SizedBox(height: 28.0),
            //   widget.store.state.getState(devicekey)["postunregistered"].error !=
            //           null
            //       ? new Text(widget.store.state
            //           .getState(devicekey)["postunregistered"]
            //           .error
            //           .toString())
            //       : null,
            // ].where((x) => x != null).toList(),
          ],
        ),
      ),
    );
  }
}
