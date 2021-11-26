import 'dart:developer';
import 'dart:ui';

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
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            // child: 
            child: Container(
              width: double.infinity,
              height: double.infinity,
              child: ListView.builder(
                itemCount: msgModels!.length,
                itemBuilder: (BuildContext context, int index) {
                  ChatMessageModel msgModel = msgModels![index];
                  return ChatView(msgModel);
                },
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Padding(
                  padding:const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: TextField(
                    onChanged: (_text) {
                      text = _text;
                    },
                    decoration:const InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8))
                      )
                    ),
                  ),
                )
              ),
              TextButton(
                onPressed: () {
                  print("发送消息");
                },
                style: TextButton.styleFrom(
                   padding: const EdgeInsets.all(16.0),
                   primary: Colors.green,
                   backgroundColor: Colors.green,
                 ),
                child: const Text("发送" ,style: TextStyle(color: Colors.white),)
              ),
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
