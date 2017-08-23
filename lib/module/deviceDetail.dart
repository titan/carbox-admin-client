import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/model/device.dart';
import 'package:adminclient/store/device.dart';

class DeviceDetailPage extends StatefulWidget {
  final String title;
  final Store store;

  DeviceDetailPage({Key key, this.title, this.store}) : super(key: key);

  @override
  _DeviceDetailPageState createState() => new _DeviceDetailPageState();
}

Device _selected;
List<DeviceDetail> _detailList;

class DeviceDetail {
  DeviceDetail({
    this.key,
    this.value,
  });
  String key;
  final value;
}

class _DeviceDetailPageState extends State<DeviceDetailPage> {
  @override
  void initState() {
    super.initState();
    widget.store.onChange.listen((state) {
      state.getState(devicekey);
    });
    Map<String, DeviceState> _states = widget.store.state.getState(devicekey);
    DeviceState selected = _states["selected"];
    _selected = selected.selected;
    _detailList = <DeviceDetail>[
      new DeviceDetail(key: "mac地址", value: _selected.mac),
      new DeviceDetail(key: "地址", value: _selected.address),
      new DeviceDetail(key: "主板型号", value: _selected.systemBoard.toString()),
      new DeviceDetail(key: "锁控型号", value: _selected.lockBoard.toString()),
      new DeviceDetail(key: "锁总个数", value: _selected.lockAmount.toString()),
      new DeviceDetail(key: "连接方式", value: _selected.wireless.toString()),
      new DeviceDetail(key: "天线类型", value: _selected.antenna.toString()),
      new DeviceDetail(key: "读卡器型号", value: _selected.cardReader.toString()),
      new DeviceDetail(key: "扬声器型号", value: _selected.speaker.toString()),
      new DeviceDetail(key: "号码", value: _selected.simNo.toString()),
      new DeviceDetail(key: "路由板型号", value: _selected.routerBoard.toString()),
    ];
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          title: new Text('设备信息'),
          centerTitle: true,
        ),
        body: new ListView(
          children: _detailList.map((DeviceDetail _deviceDetail) {
            return new Column(
              children: [
                new Container(
                  child: new ListTile(
                    title: new Text(_deviceDetail.key,
                        style: new TextStyle(
                          fontSize: 18.0,
                        )),
                    trailing: new Text(_deviceDetail.value,
                        style: new TextStyle(fontSize: 18.0)),
                  ),
                  height: 40.0,
                ),
                new Divider(height: 3.0),
              ],
            );
          }).toList(),
        ));
  }
}
