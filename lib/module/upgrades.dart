import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/model/constants.dart';
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
    this.key,
  });
  final String text;
  final String id;
  final int key;
}

final List<_Page> _pages = <_Page>[
  new _Page(text: candidateUpgradeState[1], id: "testing", key: 1),
  new _Page(text: candidateUpgradeState[-1], id: "failed", key: -1),
  new _Page(text: candidateUpgradeState[2], id: "releasing", key: 2),
  new _Page(text: candidateUpgradeState[15], id: "released", key: 15),
];

class _UpgradesPageState extends State<UpgradesPage>
    with SingleTickerProviderStateMixin {
  bool reload = false;
  TabController _controller;
  final ScrollController _scrollController = new ScrollController();
  _Page _selectedPage = _pages[0];
  Map<String, UpgradeState> _upgradeStates;

  void _handleTabSelection() {
    setState(() {
      _selectedPage = _pages[_controller.index];
      UpgradeState _state = _upgradeStates[_selectedPage.id];
      if (!_state.nomore && _state.data.length == 0) {
        fetchUpgrades(
            widget.store, _selectedPage.id, _selectedPage.key, _state.offset);
      }
    });
  }

  bool _handleScrollNotification(ScrollNotification notification) {
    if (notification.depth == 0 && notification is OverscrollNotification) {
      if (notification.overscroll > 0) {
        // got to the end of scrollable
        UpgradeState _state = _upgradeStates[_selectedPage.id];
        if (!_state.nomore) {
          fetchUpgrades(
              widget.store, _selectedPage.id, _selectedPage.key, _state.offset);
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _upgradeStates = widget.store.state.getState(upgradekey);
    _controller = new TabController(
      vsync: this,
      length: _pages.length,
    );
    _controller.addListener(_handleTabSelection);
    UpgradeState _state = _upgradeStates["testing"];
    if (!_state.nomore && _state.data.length == 0) {
      fetchUpgrades(widget.store, "testing", 1, _state.offset);
    }
    widget.store.onChange.listen((state) {
      String tag = _pages[_controller.index].id;
      UpgradeState _state = state.getState(upgradekey)[tag];
      if (!_state.nomore && _state.data.length == 0 && !_state.loading) {
        fetchUpgrades(widget.store, tag, 1, _state.offset);
      } else {
        setState(() {}); // just notify interface to refresh
      }
    });
  }

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

  Widget buildItem(
      final ThemeData theme, final UpgradeState state, final Upgrade upgrade) {
    return state.deleting && state.toDelete.id == upgrade.id
        ? new Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              new CircularProgressIndicator(),
              new Text("删除中..."),
            ],
          )
        : new ListTile(
            title: new Text(upgrade.type),
            subtitle: new Text('版本: ${upgrade.version}'),
            trailing: !state.deletable
                ? null
                : new IconButton(
                    icon: const Icon(Icons.delete),
                    color: theme.primaryColor,
                    onPressed: () {
                      deleteUpgrade(
                          widget.store, _pages[_controller.index].id, upgrade);
                    },
                  ),
            onLongPress: () {
              displayDeleteUpgradeAction(
                  widget.store, _pages[_controller.index].id);
            },
            onTap: () {
              hideDeleteUpgradeAction(
                  widget.store, _pages[_controller.index].id);
              selectUpgrade(widget.store, upgrade);
              Navigator.pushNamed(context, "/upgrade");
            },
          );
  }

  List<Widget> fillListView(final ThemeData theme, final UpgradeState state) {
    List<Widget> items =
        state.data.map((x) => buildItem(theme, state, x)).toList();
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
    UpgradeState _state = _upgradeStates[_selectedPage.id];
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
        centerTitle: true,
        bottom: new TabBar(
          controller: _controller,
          isScrollable: false,
          tabs: _pages.map((_Page page) => new Tab(text: page.text)).toList(),
        ),
      ),
      body: new TabBarView(
        controller: _controller,
        children: _pages.map((_Page page) {
          return _state.error != null
              ? new Center(child: new Text(_state.error.toString()))
              : new NotificationListener<ScrollNotification>(
                  onNotification: _handleScrollNotification,
                  child: new ListView(
                    children: fillListView(theme, _state),
                  ),
                );
        }).toList(),
      ),
      floatingActionButton: _controller.index == 0
          ? (_state.deletable
              ? new FloatingActionButton(
                  child: const Icon(Icons.cancel),
                  onPressed: () {
                    hideDeleteUpgradeAction(
                        widget.store, _pages[_controller.index].id);
                  },
                )
              : new FloatingActionButton(
                  child: const Icon(Icons.add),
                  onPressed: () {
                    selectUpgrade(widget.store, null);
                    Navigator.pushNamed(context, "/upgrade");
                  },
                ))
          : (!_state.deletable
              ? null
              : new FloatingActionButton(
                  child: const Icon(Icons.cancel),
                  onPressed: () {
                    hideDeleteUpgradeAction(
                        widget.store, _pages[_controller.index].id);
                  },
                )),
    );
  }
}
