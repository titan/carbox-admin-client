import 'package:flutter/material.dart';
import 'package:redux/redux.dart';
import 'package:adminclient/store/session.dart';

class SignInPage extends StatefulWidget {
  final String title;
  final Store store;

  SignInPage({
    Key key,
    this.title,
    this.store,
  }) : super(key: key);

  @override
  _SignInPageState createState() => new _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  String _account, _passwd;
  bool _autovalidate = false;
  bool _formWasEdited = false;

  GlobalKey<FormState> _formKey = new GlobalKey<FormState>();
  GlobalKey<FormFieldState<String>> _passwordFieldKey =
      new GlobalKey<FormFieldState<String>>();

  void showInSnackBar(String value) {
    _scaffoldKey.currentState
        .showSnackBar(new SnackBar(content: new Text(value)));
  }

  void _handleSubmitted(BuildContext context) {
    FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('请在登录前修正红色的错误');
    } else {
      form.save();
      signIn(
        widget.store,
        _account,
        _passwd,
      );
    }
  }

  String _validateAccount(String value) {
    _formWasEdited = true;
    if (value.isEmpty) return '请填写帐号';
    RegExp nameExp = new RegExp(r'^[A-za-z_0-9]+$');
    if (!nameExp.hasMatch(value)) return '请仅填写英文字母+数字';
    return null;
  }

  String _validatePassword(String value) {
    _formWasEdited = true;
    FormFieldState<String> passwordField = _passwordFieldKey.currentState;
    if (passwordField.value == null || passwordField.value.text.isEmpty)
      return '请输入密码';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Form(
        key: _formKey,
        autovalidate: _autovalidate,
        child: new ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          children: <Widget>[
            new TextFormField(
              decoration: const InputDecoration(
                icon: const Icon(Icons.person),
                hintText: '请输入帐号',
                labelText: '帐号',
              ),
              onSaved: (String value) {
                _account = value;
              },
              validator: _validateAccount,
            ),
            new TextFormField(
              key: _passwordFieldKey,
              decoration: const InputDecoration(
                icon: const Icon(Icons.vpn_key),
                hintText: '请输入密码',
                labelText: '密码',
              ),
              obscureText: true,
              onSaved: (String value) {
                _passwd = value;
              },
            ),
            new Container(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: new FlatButton(
                color: Colors.blue[500],
                textColor: Colors.white,
                child: new Text(
                  '登录',
                  style: new TextStyle(fontSize: 18.0),
                ),
                onPressed: () {
                  _handleSubmitted(context);
                },
              ),
            ),
            widget.store.state.getState(sessionkey).loading
                ? new Center(
                    child: new CircularProgressIndicator(),
                  )
                : null,
            widget.store.state.getState(sessionkey).error != null
                ? new Text(
                    widget.store.state.getState(sessionkey).error.toString())
                : null,
          ].where((x) => x != null).toList(),
        ),
      ),
    );
  }
}
