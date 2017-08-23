import 'package:flutter/material.dart';
import 'package:redux/redux.dart';

class HomeMenu {
  final String title;
  final Color color;
  final String emoji;
  final String route;
  HomeMenu({this.title, this.color, this.emoji, this.route});
}

class HomePage extends StatefulWidget {
  final String title;
  final Store store;
  HomePage({Key key, this.title, this.store}) : super(key: key);
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<HomeMenu> _menus = <HomeMenu>[
    new HomeMenu(
        title: '设备管理',
        color: new Color(0xffffffff),
        emoji: '\u{1F4BB}',
        route: "/devices"),
    new HomeMenu(
        title: '升级管理',
        color: new Color(0xffffffff),
        emoji: '\u{2708}',
        route: "/upgrades"),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
          // Here we take the value from the MyHomePage object that
          // was created by the App.build method, and use it to set
          // our appbar title.
          title: new Text(widget.title),
          centerTitle: true),
      body: new Column(
        children: <Widget>[
          new Expanded(
            child: new GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 4.0,
              crossAxisSpacing: 4.0,
              padding: const EdgeInsets.all(4.0),
              childAspectRatio: 1.0,
              children: _menus.map((HomeMenu menu) {
                return new Container(
                  child: new ClipRRect(
                    borderRadius: new BorderRadius.circular(12.0),
                    child: new InkWell(
                      onTap: () {
                        if (menu.route != null) {
                          Navigator.pushNamed(context, menu.route);
                        }
                      },
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          new Text(
                            menu.emoji,
                            style: new TextStyle(
                              fontFamily: 'EmojiSymbols',
                              fontSize: 50.0,
                              color: Colors.black,
                            ),
                          ),
                          new Text(
                            menu.title,
                            style: new TextStyle(
                              color: Colors.black,
                            ),
                          ),
                        ],
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                  ),
                  decoration: new BoxDecoration(color: menu.color),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
