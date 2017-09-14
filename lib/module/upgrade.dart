import 'dart:async';
import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/api/defination.dart';
import 'package:adminclient/model/constants.dart';
import 'package:adminclient/model/upgrade.dart';
import 'package:adminclient/module/keyvalue.dart';
import 'package:adminclient/store/session.dart';
import 'package:adminclient/store/upgrade.dart';

class UpgradePage extends StatefulWidget {
  final String title;
  final Store store;

  UpgradePage({Key key, this.title, this.store}) : super(key: key);

  @override
  _UpgradePageState createState() => new _UpgradePageState();
}

class _UpgradePageState extends State<UpgradePage> {
  Upgrade _editable = null;
  final TextEditingController _urlInputController = new TextEditingController();
  final TextEditingController _versionInputController =
      new TextEditingController();
  bool _autovalidate = false;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  StreamSubscription _subscription;
  bool _tokenExceptionReported = false;

  String _validateUrl(String value) {
    if (value.isEmpty) return '请填写下载链接';
    RegExp urlExp = new RegExp(
        r'(http|ftp|https)://[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:/~+#-]*[\w@?^=%&amp;/~+#-])?');
    if (!urlExp.hasMatch(value)) return '请填写正确的下载链接';
    return null;
  }

  String _validateVersion(String value) {
    if (value.isEmpty) return '请填写版本号';
    RegExp versionExp = new RegExp(r'^[1-9][0-9]*$');
    if (!versionExp.hasMatch(value)) return '请填写正确的版本号';
    return null;
  }

  void _handleSubmitted(BuildContext context) {
    UpgradeState _state = widget.store.state.getState(upgradekey)["selected"];
    FormState _form = _formKey.currentState;
    if (!_form.validate()) {
      _autovalidate = true;
    } else {
      _form.save();
      if (_state.selected == null) {
        createUpgrade(widget.store, _editable);
      } else {
        Upgrade _selected = _state.selected;
        if (_selected.state == _editable.state &&
            _selected.url == _editable.url &&
            _selected.type == _editable.type &&
            _selected.systemBoard == _editable.systemBoard &&
            _selected.lockBoard == _editable.lockBoard &&
            _selected.version == _editable.version) {
          // nothing to do, just rollback to view model
          selectUpgrade(widget.store, _state.selected);
        } else {
          modifyUpgrade(widget.store, _editable);
        }
      }
    }
  }

  void _syncState() {
    UpgradeState _state = widget.store.state.getState(upgradekey)["selected"];
    if (_state.selected == null) {
      _editable = new Upgrade();
      _editable.id = 0;
      _editable.state = 1;
      _editable.type = "boxos";
      _editable.systemBoard = 1;
      _editable.lockBoard = 1;
      _editable.url = "http://";
    } else {
      if (_editable == null) {
        _editable = new Upgrade();
      }
      _editable.id = _state.selected.id;
      _editable.state = _state.selected.state;
      _editable.url = _state.selected.url;
      _editable.type = _state.selected.type;
      _editable.systemBoard = _state.selected.systemBoard;
      _editable.lockBoard = _state.selected.lockBoard;
      _editable.version = _state.selected.version;
    }
    _urlInputController.text = _editable.url;
    _versionInputController.text =
        _editable.version == null || _editable.version == 0
            ? ""
            : _editable.version.toString();
  }

  @override
  void initState() {
    super.initState();
    _syncState();
    _subscription = widget.store.onChange.listen((state) {
      if (state.error != null &&
          state.error is TokenException &&
          !_tokenExceptionReported) {
        reportInvalidToken(widget.store, state.error);
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
    UpgradeState _selectedState =
        widget.store.state.getState(upgradekey)["selected"];
    Upgrade _selected = _selectedState.selected;
    Widget _body = null;
    if (_selected != null && !_selectedState.editing) {
      _body = new ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        children: <Widget>[
          new KeyValueItem(
            title: "升级编号",
            value: _editable.id.toString(),
          ),
          new KeyValueItem(
            title: "升级状态",
            value: candidateUpgradeState[_editable.state],
          ),
          new KeyValueItem(
            title: "升级类型",
            value: _editable.type,
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
            title: "下载路径",
            value: _editable.url,
          ),
          new KeyValueItem(
            title: "版本编号",
            value: _editable.version.toString(),
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
            new KeyValueItem(title: "升级编号", value: _editable.id.toString()),
            new Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Text('升级状态'),
                new DropdownButton<int>(
                  value: _editable.state,
                  onChanged: (int value) {
                    setState(() {
                      _editable.state = value;
                    });
                  },
                  items: candidateUpgradeState.keys.map((int key) {
                    return new DropdownMenuItem<int>(
                      value: key,
                      child: new Text(candidateUpgradeState[key]),
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
                new Text('升级类型'),
                new DropdownButton<String>(
                  value: _editable.type,
                  onChanged: (String value) {
                    setState(() {
                      _editable.type = value;
                    });
                  },
                  items: ["boxos", "supervisor"].map((String value) {
                    return new DropdownMenuItem<String>(
                      value: value,
                      child: new Text(value),
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
                new Text('主板型号'),
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
                new Text('锁控型号'),
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
              controller: _urlInputController,
              decoration: new InputDecoration(
                hintText: "请输入下载地址",
                labelText: '下载地址',
              ),
              validator: _validateUrl,
              keyboardType: TextInputType.url,
              onSaved: (String value) {
                _editable.url = value;
              },
            ),
            new TextFormField(
              controller: _versionInputController,
              decoration: new InputDecoration(
                hintText: "请输入版本编号",
                labelText: '版本编号',
              ),
              validator: _validateVersion,
              keyboardType: TextInputType.number,
              onSaved: (String value) {
                _editable.version = int.parse(value);
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
            editUpgrade(widget.store);
          }
        },
      ),
    );
  }
}
