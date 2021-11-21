import 'dart:developer';

import 'package:dearim/models/ContactModel.dart';
import 'package:dearim/tcp/TCPManager.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  late ContactModel model;
  ChatPage(this.model, {Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState(this.model);
}

class _ChatPageState extends State<ChatPage> {
  ContactModel model;
  _ChatPageState(this.model);
  String text = "";
  String? receiveText = "";
  @override
  void initState() {
    super.initState();
    TCPManager().registerMessageCommingCallbck((incomingIMMessageList) => {
      this.receiveText = incomingIMMessageList.last.content;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(this.model.name),
      ),
      body: Center(
          child: Column(
        children: [
          TextField(
            onChanged: (text) {
              this.text = text;
            },
          ),
          FlatButton(
            onPressed: () {
              log("message = " + text);
              TCPManager().sendMessage(text, 1001);
            },
            child: Container(
              color: Colors.red,
              child: Text("send"),
            ),
          ),
          Text(this.receiveText)
        ],
      )),
    );
  }
}
