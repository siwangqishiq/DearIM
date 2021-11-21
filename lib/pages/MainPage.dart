// ignore_for_file: file_names

import 'package:dearim/models/ContactModel.dart';
import 'package:dearim/network/Request.dart';
import 'package:dearim/pages/ChatPage.dart';
import 'package:dearim/user/UserManager.dart';
import 'package:dearim/views/ContactView.dart';
import 'package:dearim/views/ToastShowUtils.dart';
import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          MaterialButton(
            child: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              ToastShowUtils.showAlert("确定登出吗", "", context, () {
                UserManager().logout(Callback(successCallback: (data) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed("/login");
                }));
              }, () {});
            },
          )
        ],
        title: const Text(
          "展信佳",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: ListView.builder(
        itemCount: 20,
        itemBuilder: (BuildContext context, int index) {
          ContactModel contactModel = ContactModel("name", "userId");
          contactModel.message = "message";
          return ContactView(contactModel, () {
            //跳转传参
            Navigator.of(context).push(
              new PageRouteBuilder(
                pageBuilder: (BuildContext context, Animation<double> animation,
                    Animation<double> secondaryAnimation) {
                  return ChatPage(contactModel);
                },
              ),
            );
          });
        },
      ),
    );
  }
}
