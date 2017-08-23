import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/model/upgrade.dart';
import 'package:adminclient/store/upgrade.dart';

class UpgradeDetailPage extends StatefulWidget {
  final String title;
  final Store store;

  UpgradeDetailPage({Key key, this.title, this.store}) : super(key: key);

  @override
  _UpgradeDetailPageState createState() => new _UpgradeDetailPageState();
}

Upgrade _selected;
List<UpgradeDetail> _detailList;

class UpgradeDetail {
  UpgradeDetail({
    this.key,
    this.value,
  });
  String key;
  final value;
}

class _UpgradeDetailPageState extends State<UpgradeDetailPage> {
  void _savePutUpgrade(BuildContext context, Upgrade upgrade) {
    savePutUpgrade(widget.store, upgrade);
  }

  void _deleteUpgrade(BuildContext context, Upgrade upgrade) {
    deleteUpgrade(widget.store, upgrade.id);
  }

  @override
  void initState() {
    super.initState();
    widget.store.onChange.listen((state) {
      var pop = widget.store.state
                  .getState(upgradekey)["deleteupgrade"]
                  .deleted ==
              true
          ? widget.store.state.getState(upgradekey)["deleteupgrade"].error !=
                  null
              ? _showMessage(
                  widget.store.state
                      .getState(upgradekey)["deleteupgrade"]
                      .error
                      .toString(),
                  false)
              : _showMessage("删除成功", true)
          : null;
    });
    Map<String, UpgradeState> _states = widget.store.state.getState(upgradekey);
    UpgradeState selected = _states["select"];
    _selected = selected.selected;
    String _state;
    String _systemBoard;
    String _lockBoard;
    if (_selected.lockBoard == 1) {
      _lockBoard = "20路中立锁空板";
    } else {
      _lockBoard = "无";
    }
    if (_selected.systemBoard == 1) {
      _systemBoard = "A20主板";
    } else {
      _systemBoard = "无";
    }
    if (_selected.state == 1) {
      _state = "待测试";
    } else if (_selected.state == 2) {
      _state = "待发布";
    } else if (_selected.state == -1) {
      _state = "测试失败";
    } else {
      _state = "已发布";
    }
    _detailList = <UpgradeDetail>[
      new UpgradeDetail(key: "编号", value: _selected.id.toString()),
      new UpgradeDetail(key: "应用类型", value: _selected.type),
      new UpgradeDetail(key: "锁控型号", value: _lockBoard),
      new UpgradeDetail(key: "主板型号", value: _systemBoard),
      new UpgradeDetail(key: "状态", value: _state),
      new UpgradeDetail(key: "下载路径", value: _selected.url),
      new UpgradeDetail(key: "版本号", value: _selected.version.toString()),
    ];
  }

  void _showMessage(text, state) {
    showDialog<Null>(
        context: context,
        child: new AlertDialog(content: new Text(text), actions: <Widget>[
          new FlatButton(
              onPressed: () {
                if (state == true) {
                  Navigator.pushNamed(context, "/upgrades");
                } else {
                  Navigator.pop(context);
                }
              },
              child: const Text('确认'))
        ]));
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var content = _detailList.map((UpgradeDetail _upgradeDetail) {
      return new Container(
        child: new ListTile(
          title: new Text(
            _upgradeDetail.key,
            style: new TextStyle(
              fontSize: 18.0,
            ),
            overflow: TextOverflow.clip,
          ),
          subtitle: new Text(
            _upgradeDetail.value,
            style: new TextStyle(fontSize: 15.0),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      );
    }).toList();
    content.addAll([
      new Container(
        padding: const EdgeInsets.only(left: 48.0, right: 48.0),
        child: new FlatButton(
          color: Colors.blue[500],
          textColor: Colors.white,
          child: new Text(
            '修改信息',
            style: new TextStyle(fontSize: 15.0),
          ),
          onPressed: () {
            _savePutUpgrade(context, _selected);
            Navigator.pushNamed(context, "/upgradePost");
          },
        ),
      ),
      new Container(
        padding: const EdgeInsets.only(left: 48.0, right: 48.0, top: 20.0),
        child: new FlatButton(
          color:
              widget.store.state.getState(upgradekey)["deleteupgrade"].loading
                  ? null
                  : Colors.blue[500],
          textColor: Colors.white,
          child:
              widget.store.state.getState(upgradekey)["deleteupgrade"].loading
                  ? new Center(
                      child: new CircularProgressIndicator(),
                    )
                  : new Text(
                      '删除信息',
                      style: new TextStyle(fontSize: 15.0),
                    ),
          onPressed: () {
            _deleteUpgrade(context, _selected);
          },
        ),
      ),
      new Container(
        padding: const EdgeInsets.only(left: 48.0, right: 48.0, top: 20.0),
        child: new FlatButton(
          color: Colors.blue[500],
          textColor: Colors.white,
          child: new Text(
            '返回列表页',
            style: new TextStyle(fontSize: 15.0),
          ),
          onPressed: () {
            // _savePutUpgrade(context, _selected);
            Navigator.pushNamed(context, "/upgrades");
          },
        ),
      ),
      new Container(child: new SizedBox(height: 28.0)),
    ]);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text('设备信息'),
        centerTitle: true,
      ),
      body: new ListView(
        children: content.toList(),
      ),
    );
  }
}
