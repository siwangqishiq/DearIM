// ignore_for_file: file_names

import 'package:dearim/views/ToastShowUtils.dart';
import 'package:dearim/network/Request.dart';
import 'package:dearim/user/UserManager.dart';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  //TODO: wmy test
  String username = "wenmingyan";
  String password = "111111";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
      ),
      body: Container(
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            SizedBox(
              height: 100,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: "input login"),
              onChanged: (String text) {
                this.username = text;
                Logger().d(text);
              },
            ),
            SizedBox(
              height: 20,
            ),
            TextField(
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(hintText: "input password"),
              obscureText: true,
              onChanged: (String text) {
                this.password = text;
                Logger().d(text);
              },
            ),
            SizedBox(
              height: 20,
            ),
            MaterialButton(
                onPressed: () {
                  if (this.username.length == 0 || this.password.length == 0) {
                    ToastShowUtils.show("用户名或密码为空", context);
                    return;
                  }
                  login();
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 400,
                    height: 40,
                    color: Colors.red,
                    child: Center(
                      child: Text(
                        "Login",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void login() {
    UserManager.getInstance().login(
        this.username,
        this.password,
        Callback(successCallback: (data) {
          Navigator.of(context).pop();
          Navigator.of(context).pushNamed("/main");
          FocusManager.instance.primaryFocus!.unfocus();
        }, failureCallback: (code, errorStr, data) {
          ToastShowUtils.show(errorStr, context);
        }));
  }
}
