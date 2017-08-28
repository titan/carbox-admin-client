import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/model/upgrade.dart';
import 'package:adminclient/store/upgrade.dart';

class UpgradesPage extends StatefulWidget {
  final String title;
  final Store store;
  UpgradesPage({Key key, this.title, this.store}) : super(key: key);
  @override
  _UpgradesPageState createState() => new _UpgradesPageState();
}

class _Page {
  _Page({
    this.text,
    this.id,
  });
  final String text;
  final String id;
}

Map<String, List<Upgrade>> upgradeKinds = {
  "test-waiting": <Upgrade>[],
  "test-failed": <Upgrade>[],
  "publish-waiting": <Upgrade>[],
  "pubilshed": <Upgrade>[],
};

class _UpgradesPageState extends State<UpgradesPage>
    with SingleTickerProviderStateMixin {
  void _saveSelectUpgrade(BuildContext context, Upgrade upgrade) {
    selectUpgrade(widget.store, upgrade);
  }

  void _savePutUpgrade(BuildContext context, Upgrade upgrade) {
    savePutUpgrade(widget.store, upgrade);
  }

  void _reload(Store store) {
    setState(() {
      index = _controller.index;
      if (index == 0) {
        fetch1Upgrades(widget.store, 0);
      } else if (index == 1) {
        fetch2Upgrades(widget.store, 0);
      } else if (index == 2) {
        fetch3Upgrades(widget.store, 0);
      } else {
        fetch4Upgrades(widget.store, 0);
      }
    });
  }

  bool reload = false;
  TabController _controller;
  int index = 0;
  void _handleTabSelection() {
    setState(() {
      index = _controller.index;
      if (index == 0) {
        Map<String, UpgradeState> _states =
            widget.store.state.getState(upgradekey);
        UpgradeState _upgrades = _states["test-waiting"];
        if (!_upgrades.nomore && _upgrades.data.length == 0) {
          fetch1Upgrades(widget.store, 0);
        }
      } else if (index == 1) {
        Map<String, UpgradeState> _states =
            widget.store.state.getState(upgradekey);
        UpgradeState _upgrades = _states["test-failed"];
        if (!_upgrades.nomore && _upgrades.data.length == 0) {
          fetch2Upgrades(widget.store, 0);
        }
      } else if (index == 2) {
        Map<String, UpgradeState> _states =
            widget.store.state.getState(upgradekey);
        UpgradeState _upgrades = _states["publish-waiting"];
        if (!_upgrades.nomore && _upgrades.data.length == 0) {
          fetch3Upgrades(widget.store, 0);
        }
      } else {
        Map<String, UpgradeState> _states =
            widget.store.state.getState(upgradekey);
        UpgradeState _upgrades = _states["published"];
        if (!_upgrades.nomore && _upgrades.data.length == 0) {
          fetch4Upgrades(widget.store, 0);
        }
      }
    });
  }

  @override
  void initState() {
    Map<String, UpgradeState> _states = widget.store.state.getState(upgradekey);
    _controller = new TabController(vsync: this, length: _allPages.length);
    _controller.addListener(_handleTabSelection);
    super.initState();
    UpgradeState _upgrades = _states["test-waiting"];
    if (!_upgrades.nomore && _upgrades.data.length == 0) {
      fetch1Upgrades(widget.store, _upgrades.offset);
    }
    widget.store.onChange.listen((state) {});
  }

  final List<_Page> _allPages = <_Page>[
    new _Page(text: '待测试', id: "test-waiting"),
    new _Page(text: '测试失败', id: "test-failed"),
    new _Page(text: '待发布', id: "publish-waiting"),
    new _Page(text: '已发布', id: "published"),
  ];
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget popPage() {
    return new Container(
      child: const Center(
        child: const CupertinoActivityIndicator(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(
            widget.store.state.getState(upgradekey)["fetchupgrades"].error ==
                    null
                ? "设备管理"
                : "错误提示"),
        centerTitle: true,
        bottom: new TabBar(
          // 控件的选择和动画状态
          // 标签栏是否可以水平滚动
          controller: _controller,
          isScrollable: true,
          // 标签控件的列表
          tabs:
              _allPages.map((_Page page) => new Tab(text: page.text)).toList(),
        ),
        actions: <Widget>[
          new PopupMenuButton<BottomNavigationBarType>(
            onSelected: (BottomNavigationBarType value) {
              if (value == BottomNavigationBarType.fixed) {
                _reload(widget.store);
              }
            },
            itemBuilder: (BuildContext context) =>
                <PopupMenuItem<BottomNavigationBarType>>[
                  const PopupMenuItem<BottomNavigationBarType>(
                    value: BottomNavigationBarType.fixed,
                    child: const Text('刷新'),
                  ),
                ],
          )
        ],
      ),
      body: widget.store.state.getState(upgradekey)["fetchupgrades"].loading
          ? popPage()
          : widget.store.state.getState(upgradekey)["fetchupgrades"].error ==
                  null
              ? new Container(
                  child: new Column(children: <Widget>[
                    new Expanded(
                      child: new TabBarView(
                          controller: _controller,
                          children: _allPages.map((_Page page) {
                            return new ListView(
                              children: widget.store.state
                                  .getState(upgradekey)[page.id]
                                  .data
                                  .map((Upgrade upgrade) {
                                return new Container(
                                  padding: const EdgeInsets.only(top: 0.0),
                                  child: new ListTile(
                                    title: new Text("状态：" + page.text,
                                        style: new TextStyle(fontSize: 18.0)),
                                    subtitle: new Text(
                                        upgrade.type +
                                            "----" +
                                            upgrade.version.toString() +
                                            ".0.0",
                                        style: new TextStyle(fontSize: 18.0)),
                                    trailing: index == 3
                                        ? null
                                        : new IconButton(
                                            icon: const Icon(Icons.mode_edit),
                                            color:
                                                Theme.of(context).primaryColor,
                                            onPressed: () {
                                              _savePutUpgrade(context, upgrade);
                                              Navigator.pushNamed(
                                                  context, "/upgradePost");
                                            },
                                          ),
                                    onTap: () {
                                      _saveSelectUpgrade(context, upgrade);
                                      Navigator.pushNamed(
                                          context, "/upgradeDetail");
                                    },
                                  ),
                                  height: 50.0,
                                );
                              }).toList(),
                            );
                          }).toList()),
                    ),
                    index == 0
                        ? new Align(
                            alignment: FractionalOffset.bottomRight,
                            child: new FloatingActionButton(
                              child: const Icon(Icons.add),
                              onPressed: () {
                                postWaiting(widget.store);
                                Navigator.pushNamed(context, "/upgradePost");
                              },
                            ),
                          )
                        : new SizedBox(height: 28.0),
                  ]),
                )
              : new Container(
                  child: new Center(
                    child: new Text(
                        "数据异常,请稍后重试:\n" +
                            widget.store.state
                                .getState(upgradekey)["fetchupgrades"]
                                .error
                                .toString(),
                        style:
                            const TextStyle(fontSize: 18.0, color: Colors.red)),
                  ),
                ),
    );
  }
}
