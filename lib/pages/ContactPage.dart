import 'dart:developer';

import 'package:dearim/Pages/ChatPage.dart';
import 'package:dearim/models/ContactModel.dart';
import 'package:dearim/network/Request.dart';
import 'package:dearim/views/ContactView.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  ContactPage({Key? key}) : super(key: key);

  @override
  _ContactPageState createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  List<ContactModel> models = [
    ContactModel("wenmingyan", 1002),
    ContactModel("panyi", 1001)
  ];
  @override
  void initState() {
    super.initState();
    requestChatList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("通讯录"),
      // ),
      body: ListView.builder(
        itemCount: this.models.length,
        itemBuilder: (BuildContext context, int index) {
          ContactModel contactModel = this.models[index];
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

  requestChatList() {
    Request().postRequest(
      "/contacts",
      {},
      Callback(successCallback: (data) {
        this.models.clear();
        List list = data["list"];
        for (Map item in list) {
          ContactModel model = new ContactModel(item["name"], item["uid"]);
          model.avatar = item["avatar"] ?? "";
          this.models.add(model);
        }
        setState(() {});
      }, failureCallback: (code, msgStr, data) {
        log(data);
      }),
    );
  }
}
