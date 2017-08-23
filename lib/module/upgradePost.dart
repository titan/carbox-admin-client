import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/store/upgrade.dart';
import 'package:adminclient/model/upgrade.dart';

class UpgradePostPage extends StatefulWidget {
  final String title;
  final Store store;

  UpgradePostPage({Key key, this.title, this.store}) : super(key: key);

  @override
  _UpgradePostPageState createState() => new _UpgradePostPageState();
}

Upgrade _selected;
String _state;
bool _putwaiting = false;
String _newState;
Upgrade newupgrade = new Upgrade();

int _systemBoard = 1, _version = 1, _lockBoard = 1;
String _url = "http://static.fengchaohuzhu.com/box/os/";
String _type = "boxos";

class _UpgradePostPageState extends State<UpgradePostPage> {
  void _handle1Input() {
    setState(() {
      _url = _input1Controller.text;
    });
  }

  void _handle2Input() {
    setState(() {
      if (_input2Controller.text != "") {
        _version = int.parse(_input2Controller.text);
      }
    });
  }

  final TextEditingController _input1Controller = new TextEditingController();
  final TextEditingController _input2Controller = new TextEditingController();
  final TextEditingController _input3Controller = new TextEditingController();
  @override
  void initState() {
    super.initState();
    Map<String, UpgradeState> _states = widget.store.state.getState(upgradekey);
    UpgradeState selected = _states["putupgrade"];
    _selected = selected.put;
    if (selected.putWaiting == true && _selected != null) {
      _putwaiting = true;
      switch (_selected.state) {
        case 1:
          _state = "待测试";
          break;
        case -1:
          _state = "测试失败";
          break;
        case -2:
          _state = "待发布";
          break;
        case 15:
          _state = "已发布";
          break;
      }
      _input3Controller.text = _state;
    } else {
      _putwaiting = false;
    }
    _input1Controller.text = _selected != null ? _selected.url : _url;
    _input1Controller.addListener(_handle1Input);
    _input2Controller.text =
        _selected != null ? _selected.version.toString() : _version.toString();
    _input2Controller.addListener(_handle2Input);
    widget.store.onChange.listen((state) {
      var pop =
          widget.store.state.getState(upgradekey)["postupgrade"].postend == true
              ? widget.store.state.getState(upgradekey)["postupgrade"].error !=
                      null
                  ? _showMessage(
                      widget.store.state
                          .getState(upgradekey)["postupgrade"]
                          .error
                          .toString(),
                      false)
                  : _showMessage("提交成功", true)
              : null;
      var pup = widget.store.state.getState(upgradekey)["putupgrade"].putend ==
              true
          ? widget.store.state.getState(upgradekey)["putupgrade"].error != null
              ? _showMessage(
                  widget.store.state
                      .getState(upgradekey)["putupgrade"]
                      .error
                      .toString(),
                  false)
              : _showMessage("修改成功", true)
          : null;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  bool _autovalidate = false;
  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  void _handleSubmitted(BuildContext context, String _newState) {
    Upgrade upgrade = new Upgrade();
    upgrade.lockBoard = _lockBoard;
    upgrade.systemBoard = _systemBoard;
    upgrade.url = _url;
    upgrade.version = _version;
    upgrade.type = _type;
    upgrade.state = 1;
    postUpgrade(widget.store, upgrade);
    reloadUpgrade(widget.store, "test-waiting");
  }

  void _putUpgrade(BuildContext context) {
    newupgrade.id = _selected.id;
    newupgrade.lockBoard = _selected.lockBoard;
    newupgrade.systemBoard = _selected.systemBoard;
    newupgrade.url = _selected.url;
    newupgrade.version = _selected.version;
    newupgrade.type = _selected.type;
    switch (_newState) {
      case "待测试":
        newupgrade.state = 1;
        reloadUpgrade(widget.store, "test-waiting");
        break;
      case "测试失败":
        reloadUpgrade(widget.store, "test-failed");
        newupgrade.state = -1;
        break;
      case "待发布":
        reloadUpgrade(widget.store, "publish-waiting");
        newupgrade.state = 2;
        break;
      case "已发布":
        reloadUpgrade(widget.store, "published");
        newupgrade.state = 15;
        break;
    }
    putUpgrade(widget.store, newupgrade);
  }

  String _system1Board = "A20主板", _lock1Board = "20路中立锁控板";
  void _showMessage(text, state) {
    showDialog<Null>(
        context: context,
        child: new AlertDialog(content: new Text(text), actions: <Widget>[
          new FlatButton(
              onPressed: () {
                if (state == true) {
                  Navigator.popUntil(context, ModalRoute.withName('/upgrades'));
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
        title: _putwaiting ? new Text("信息修改") : new Text('信息提交'),
        centerTitle: true,
      ),
      body: new Form(
        key: _formKey,
        autovalidate: _autovalidate,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            _putwaiting
                ? new ListTile(
                    title: const Text('状态'),
                    trailing: new DropdownButton<String>(
                      value: _state,
                      onChanged: (String newValue) {
                        setState(() {
                          _state = newValue;
                          _newState = newValue;
                        });
                      },
                      items: <String>['待测试', '测试失败', '待发布', '已发布']
                          .map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                    ),
                  )
                : new ListTile(
                    title: new Text("状态",
                        style: new TextStyle(
                          fontSize: 16.0,
                        )),
                    trailing:
                        new Text("待测试", style: new TextStyle(fontSize: 18.0)),
                  ),
            _putwaiting
                ? new ListTile(
                    title: new Text("下载地址",
                        style: new TextStyle(
                          fontSize: 16.0,
                        )),
                    subtitle: new Text(
                      _selected.url,
                      style: new TextStyle(fontSize: 15.0),
                      overflow: TextOverflow.ellipsis,
                    ),
                  )
                : new ListTile(
                    title: new Text("下载地址",
                        style: new TextStyle(
                          fontSize: 16.0,
                        )),
                    trailing: new Container(
                      child: new TextField(
                        controller: _input1Controller,
                        decoration: new InputDecoration(hintText: "请输入下载地址"),
                        maxLines: 2,
                      ),
                      width: 200.0,
                    )),
            _putwaiting
                ? new ListTile(
                    title: new Text("版本号",
                        style: new TextStyle(
                          fontSize: 16.0,
                        )),
                    trailing: new Text(_selected.version.toString() + ".0.0",
                        style: new TextStyle(fontSize: 18.0)),
                  )
                : new ListTile(
                    title: new Text("版本号",
                        style: new TextStyle(
                          fontSize: 16.0,
                        )),
                    trailing: new Container(
                      child: new TextField(
                        controller: _input2Controller,
                        decoration: new InputDecoration(hintText: "请输入当前测试版本号"),
                        maxLines: 1,
                      ),
                      width: 200.0,
                    )),
            _putwaiting
                ? new ListTile(
                    title: new Text("类型",
                        style: new TextStyle(
                          fontSize: 16.0,
                        )),
                    trailing: new Text(_selected.type,
                        style: new TextStyle(fontSize: 18.0)),
                  )
                : new ListTile(
                    title: const Text('类型'),
                    trailing: new DropdownButton<String>(
                      value: _type,
                      onChanged: (String newValue) {
                        setState(() {
                          _type = newValue;
                        });
                      },
                      items:
                          <String>['boxos', 'supervisor'].map((String value) {
                        return new DropdownMenuItem<String>(
                          value: value,
                          child: new Text(value),
                        );
                      }).toList(),
                    ),
                  ),
            _putwaiting
                ? new ListTile(
                    title: new Text("主板型号",
                        style: new TextStyle(
                          fontSize: 16.0,
                        )),
                    trailing: new Text(_selected.systemBoard.toString(),
                        style: new TextStyle(fontSize: 18.0)),
                  )
                : new ListTile(
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
            _putwaiting
                ? new ListTile(
                    title: new Text("锁控型号",
                        style: new TextStyle(
                          fontSize: 16.0,
                        )),
                    trailing: new Text(_selected.lockBoard.toString(),
                        style: new TextStyle(fontSize: 18.0)),
                  )
                : new ListTile(
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
            new Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: new FlatButton(
                color: widget.store.state
                        .getState(upgradekey)[
                            _putwaiting ? "putupgrade" : "postupgrade"]
                        .loading
                    ? null
                    : Colors.blue[500],
                textColor: Colors.white,
                child: widget.store.state
                        .getState(upgradekey)[
                            _putwaiting ? "putupgrade" : "postupgrade"]
                        .loading
                    ? new Center(
                        child: new CircularProgressIndicator(),
                      )
                    : new Text(
                        _putwaiting ? "确认修改" : '确认提交',
                        style: new TextStyle(fontSize: 18.0),
                      ),
                onPressed: () {
                  _putwaiting
                      ? _putUpgrade(context)
                      : _handleSubmitted(context, _newState);
                },
              ),
            ),
            new SizedBox(height: 28.0),
          ],
        ),
      ),
    );
  }
}
