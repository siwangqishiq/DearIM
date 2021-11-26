import 'dart:developer';

import 'package:dearim/datas/chat_data.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/tcp/tcp_manager.dart';
import 'package:dearim/views/chat_view.dart';
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
  List<ChatMessageModel>? msgModels = [];
  @override
  void initState() {
    super.initState();
    msgModels = ChatDataManager.getInstance()!.getMsgModels(model.userId);
    TCPManager().registerMessageCommingCallbck((incomingIMMessageList) {
      // log(this.receiveText!);
      setState(() {
        // this.receiveText = incomingIMMessageList.last.content;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          model.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: Row(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: msgModels!.length,
              itemBuilder: (BuildContext context, int index) {
                ChatMessageModel msgModel = msgModels![index];
                return ChatView(msgModel);
              },
            ),
          ),
          Column(
            children: [
              TextField(
                onChanged: (text) {
                  this.text = text;
                },
              ),
              FlatButton(
                  onPressed: () {
                    log("message");
                  },
                  child: const Text("发送")),
            ],
          )
        ],
      ),
      // Center(
      //     child: Column(
      //   children: [
      //     TextField(
      //       onChanged: (text) {
      //         this.text = text;
      //       },
      //     ),
      //     FlatButton(
      //       onPressed: () {
      //         log("message = " + text);
      //         TCPManager().sendMessage(text, this.model.userId);
      //       },
      //       child: Container(
      //         color: Colors.red,
      //         child: Text("send"),
      //       ),
      //     ),
      //     Text(this.receiveText!),
      //   ],
      // )),
    );
  }
}
