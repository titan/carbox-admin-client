import 'dart:async';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/model/constants.dart';
import 'package:adminclient/model/device.dart';
import 'package:adminclient/module/keyvalue.dart';
import 'package:adminclient/store/device.dart';
import 'package:adminclient/store/session.dart';

class DevicePage extends StatefulWidget {
  final String title;
  final Store store;

  DevicePage({Key key, this.title, this.store}) : super(key: key);

  @override
  _DevicePageState createState() => new _DevicePageState();
}

class _DevicePageState extends State<DevicePage> {
  Device _editable = null;
  Device _selected = null;
  final TextEditingController _addressInputController =
      new TextEditingController();
  final TextEditingController _amountInputController =
      new TextEditingController();
  final TextEditingController _simInputController = new TextEditingController();
  bool _autovalidate = false;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  StreamSubscription _subscription;
  bool _tokenExceptionReported = false;

  String _validateAddress(String value) {
    if (value.isEmpty) return '请填写安装地址';
    return null;
  }

  String _validateAmount(String value) {
    if (value.isEmpty) return '请填写门锁个数';
    RegExp amountExp = new RegExp(r'^[1-9][0-9]*$');
    if (!amountExp.hasMatch(value)) return '请填写正确的门锁个数';
    return null;
  }

  String _validateSim(String value) {
    if (value.isEmpty) return '请填写SIM卡号';
    RegExp phoneExp = new RegExp(r'^[1-9][0-9]*$');
    if (!phoneExp.hasMatch(value)) return '请填写正确的SIM卡号';
    if (value.length != 11) return '请填写正确的SIM卡号';
    return null;
  }

  void _handleSubmitted(BuildContext context) {
    DeviceState _state = widget.store.state.getState(devicekey)["selected"];
    FormState _form = _formKey.currentState;
    if (!_form.validate()) {
      _autovalidate = true;
    } else {
      _form.save();
      if (_state.selected.address == null) {
        registerDevice(widget.store, _editable);
      } else {
        if (_selected.mac == _editable.mac &&
            _selected.address == _editable.address &&
            _selected.systemBoard == _editable.systemBoard &&
            _selected.lockBoard == _editable.lockBoard &&
            _selected.lockAmount == _editable.lockAmount &&
            _selected.wireless == _editable.wireless &&
            _selected.antenna == _editable.antenna &&
            _selected.cardReader == _editable.cardReader &&
            _selected.speaker == _editable.speaker &&
            _selected.simNo == _editable.simNo &&
            _selected.routerBoard == _editable.routerBoard) {
          // nothing to do, just rollback to view model
          selectRegisteredDevice(widget.store, _state.selected);
        } else {
          modifyDevice(widget.store, _editable);
        }
      }
    }
  }

  void _syncState() {
    DeviceState _state = widget.store.state.getState(devicekey)["selected"];
    if (_state.selected == null) {
      _editable = new Device();
      _editable.mac = "";
      _editable.address = "";
      _editable.pin = "";
      _editable.systemBoard = 1;
      _editable.lockBoard = 1;
      _editable.lockAmount = 18;
      _editable.wireless = 1;
      _editable.antenna = 1;
      _editable.cardReader = 1;
      _editable.speaker = 1;
      _editable.simNo = 0;
      _editable.routerBoard = 1;
    } else {
      _selected = _state.selected;
      if (_editable == null) {
        _editable = new Device();
      }
      _editable.mac = _selected.mac;
      _editable.address = _selected.address;
      _editable.pin = _selected.pin;
      _editable.systemBoard = _selected.systemBoard ?? 1;
      _editable.lockBoard = _selected.lockBoard ?? 1;
      _editable.lockAmount = _selected.lockAmount;
      _editable.wireless = _selected.wireless ?? 1;
      _editable.antenna = _selected.antenna ?? 1;
      _editable.cardReader = _selected.cardReader ?? 1;
      _editable.speaker = _selected.speaker ?? 1;
      _editable.simNo = _selected.simNo;
      _editable.routerBoard = _selected.routerBoard ?? 1;
    }
    _addressInputController.text = _editable.address;
    _amountInputController.text =
        _editable.lockAmount == null ? "" : _editable.lockAmount.toString();
    _simInputController.text =
        _editable.simNo == null ? "" : _editable.simNo.toString();
  }

  @override
  void initState() {
    super.initState();
    _syncState();
    _subscription = widget.store.onChange.listen((state) {
      DeviceState _state = state.getState(devicekey)["selected"];
      if (_state.error != null &&
          _state.error is TokenException &&
          !_tokenExceptionReported) {
        reportInvalidToken(widget.store, _state.error);
        _tokenExceptionReported = true;
        Navigator.of(context).popUntil((route) {
          if (route is MaterialPageRoute && route.settings.name == "/") {
            return true;
          }
          return false;
        });
      } else {
        _tokenExceptionReported = false;
        _syncState();
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    _subscription.cancel();
  }

  @override
  Widget build(BuildContext context) {
    DeviceState _selectedState =
        widget.store.state.getState(devicekey)["selected"];
    Widget _body = null;
    if (_selected != null && !_selectedState.editing) {
      _body = new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new KeyValueItem(
            title: "MAC地址",
            value: _editable.mac,
          ),
          new KeyValueItem(
            title: "安装地址",
            value: _editable.address,
          ),
          new KeyValueItem(
            title: "主板型号",
            value: candidateSystemBoards[_editable.systemBoard],
          ),
          new KeyValueItem(
            title: "锁控型号",
            value: candidateLockBoards[_editable.lockBoard],
          ),
          new KeyValueItem(
            title: "门锁个数",
            value: _editable.lockAmount.toString(),
          ),
          new KeyValueItem(
            title: "网络类型",
            value: candidateWireless[_editable.wireless],
          ),
          new KeyValueItem(
            title: "天线类型",
            value: candidateAntenna[_editable.antenna],
          ),
          new KeyValueItem(
            title: "读卡器型号",
            value: candidateCardReader[_editable.cardReader],
          ),
          new KeyValueItem(
            title: "扬声器型号",
            value: candidateSpeaker[_editable.speaker],
          ),
          new KeyValueItem(
            title: "路由板型号",
            value: candidateRouter[_editable.routerBoard],
          ),
          new KeyValueItem(
            title: "SIM卡号",
            value: _editable.simNo.toString(),
          ),
        ],
      );
    } else {
      _body = new Form(
        key: _formKey,
        autovalidate: _autovalidate,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            new KeyValueItem(
              title: "MAC地址",
              value: _editable.mac,
            ),
            new TextFormField(
              controller: _addressInputController,
              decoration: new InputDecoration(
                hintText: "请输入安装地址",
                labelText: "安装地址",
              ),
              validator: _validateAddress,
              onSaved: (String value) {
                _editable.address = value;
              },
            ),
            new Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text("主板型号"),
                new DropdownButton<int>(
                  value: _editable.systemBoard,
                  onChanged: (int value) {
                    setState(() {
                      _editable.systemBoard = value;
                    });
                  },
                  items: candidateSystemBoards.keys.map((int key) {
                    return new DropdownMenuItem<int>(
                      value: key,
                      child: new Text(candidateSystemBoards[key]),
                    );
                  }).toList(),
                ),
              ],
            ),
            new Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text("锁控型号"),
                new DropdownButton<int>(
                  value: _editable.lockBoard,
                  onChanged: (int value) {
                    setState(() {
                      _editable.lockBoard = value;
                    });
                  },
                  items: candidateLockBoards.keys.map((int key) {
                    return new DropdownMenuItem<int>(
                      value: key,
                      child: new Text(candidateLockBoards[key]),
                    );
                  }).toList(),
                ),
              ],
            ),
            new TextFormField(
              controller: _amountInputController,
              decoration: new InputDecoration(
                hintText: "请输入门锁个数",
                labelText: "门锁个数",
              ),
              validator: _validateAmount,
              keyboardType: TextInputType.number,
              onSaved: (String value) {
                _editable.lockAmount = value == "" ? 0 : int.parse(value);
              },
            ),
            new Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text("网络类型"),
                new DropdownButton<int>(
                  value: _editable.wireless,
                  onChanged: (int value) {
                    setState(() {
                      _editable.wireless = value;
                    });
                  },
                  items: candidateWireless.keys.map((int key) {
                    return new DropdownMenuItem<int>(
                      value: key,
                      child: new Text(candidateWireless[key]),
                    );
                  }).toList(),
                ),
              ],
            ),
            new Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text("天线类型"),
                new DropdownButton<int>(
                  value: _editable.antenna,
                  onChanged: (int value) {
                    setState(() {
                      _editable.antenna = value;
                    });
                  },
                  items: candidateAntenna.keys.map((int key) {
                    return new DropdownMenuItem<int>(
                      value: key,
                      child: new Text(candidateAntenna[key]),
                    );
                  }).toList(),
                ),
              ],
            ),
            new Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text("读卡器型号"),
                new DropdownButton<int>(
                  value: _editable.cardReader,
                  onChanged: (int value) {
                    setState(() {
                      _editable.cardReader = value;
                    });
                  },
                  items: candidateCardReader.keys.map((int key) {
                    return new DropdownMenuItem<int>(
                      value: key,
                      child: new Text(candidateCardReader[key]),
                    );
                  }).toList(),
                ),
              ],
            ),
            new Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text("扬声器型号"),
                new DropdownButton<int>(
                  value: _editable.speaker,
                  onChanged: (int value) {
                    setState(() {
                      _editable.speaker = value;
                    });
                  },
                  items: candidateSpeaker.keys.map((int key) {
                    return new DropdownMenuItem<int>(
                      value: key,
                      child: new Text(candidateSpeaker[key]),
                    );
                  }).toList(),
                ),
              ],
            ),
            new Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text("路由板型号"),
                new DropdownButton<int>(
                  value: _editable.routerBoard,
                  onChanged: (int value) {
                    setState(() {
                      _editable.routerBoard = value;
                    });
                  },
                  items: candidateRouter.keys.map((int key) {
                    return new DropdownMenuItem<int>(
                      value: key,
                      child: new Text(candidateRouter[key]),
                    );
                  }).toList(),
                ),
              ],
            ),
            new TextFormField(
              controller: _simInputController,
              decoration: new InputDecoration(
                hintText: "请输入SIM卡号",
                labelText: "SIM卡号",
              ),
              validator: _validateSim,
              keyboardType: TextInputType.phone,
              onSaved: (String value) {
                _editable.simNo = value == "" ? 0 : int.parse(value);
              },
            ),
            _selectedState.loading
                ? new Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      new CircularProgressIndicator(),
                      new Text("保存中..."),
                    ],
                  )
                : (_selectedState.error != null
                    ? new Center(
                        child: new Text(_selectedState.error.toString()),
                      )
                    : null)
          ].where((x) => x != null).toList(),
        ),
      );
    }
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        centerTitle: true,
      ),
      body: _body,
      floatingActionButton: new FloatingActionButton(
        child: _selectedState.editing
            ? const Icon(Icons.done)
            : const Icon(Icons.edit),
        onPressed: () {
          if (_selectedState.editing) {
            _handleSubmitted(context);
          } else {
            editDevice(widget.store);
          }
        },
      ),
    );
  }
}
