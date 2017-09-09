import 'package:flutter/material.dart';

const double kKeyValueItemHeight = 48.0;

class KeyValueItem extends StatelessWidget {
  final String title;
  final String value;
  final double height;
  KeyValueItem({
    Key key,
    this.title,
    this.value,
    this.height = kKeyValueItemHeight,
  })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return new Container(
      height: height,
      //padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: new BoxDecoration(
        color: theme.canvasColor,
        border: new Border(
          bottom: new BorderSide(
            color: theme.dividerColor,
          ),
        ),
      ),
      child: new Container(
        child: new Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            new Text(title),
            new Expanded(
              child: new Text(
                value,
                textAlign: TextAlign.right,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
