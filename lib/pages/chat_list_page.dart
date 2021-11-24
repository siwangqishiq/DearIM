import 'package:dearim/models/contact_model.dart';

import 'package:dearim/views/contact_view.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

// ignore: must_be_immutable
class ChatListPage extends StatefulWidget {
  const ChatListPage({Key? key}) : super(key: key);

  @override
  _ChatListPageState createState() => _ChatListPageState();
}

class _ChatListPageState extends State<ChatListPage> {
  List<ContactModel> models = [
    ContactModel("wenmingyan", 1002),
    ContactModel("panyi", 1001)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("聊天"),
      // ),
      body: ListView.builder(
        itemCount: models.length,
        itemBuilder: (BuildContext context, int index) {
          ContactModel contactModel = models[index];
          //TODO: wmy test
          contactModel.message = "message";
          return ContactView(contactModel, () {
            //跳转传参
            Navigator.of(context).push(
              PageRouteBuilder(
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
