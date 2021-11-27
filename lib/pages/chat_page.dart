import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:dearim/datas/chat_data.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/tcp/tcp_manager.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/views/chat_view.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  late ContactModel model;
  ChatPage(this.model, {Key? key}) : super(key: key);

  @override
  _ChatPageState createState() => _ChatPageState(model);
}

class _ChatPageState extends State<ChatPage> {
  ContactModel model;
  _ChatPageState(this.model);
  String text = "";
  String? receiveText = "";
  List<ChatMessageModel>? msgModels = [];
  final ScrollController _listViewController = ScrollController();
  @override
  void initState() {
    super.initState();
    msgModels = ChatDataManager.getInstance()!.getMsgModels(model.userId);
    TCPManager().registerMessageCommingCallbck((incomingIMMessageList) {
      setState(() {
        receiveText = incomingIMMessageList.last.content;
        log(receiveText!);
        ChatMessageModel msgModel = ChatMessageModel();
        msgModel.uid = model.user.uid;
        msgModel.context = receiveText!;
        ChatDataManager.getInstance()!.addMessage(msgModel, model.user);
        msgModels = ChatDataManager.getInstance()!.getMsgModels(model.userId);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController _textFieldController = TextEditingController();
    scrollToBottom();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          model.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              // child:
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                // width: MediaQuery.of(context).size.width,
                // height: double.infinity,
                child: ListView.builder(
                  controller: _listViewController,
                  itemCount: msgModels!.length,
                  itemBuilder: (BuildContext context, int index) {
                    ChatMessageModel msgModel = msgModels![index];
                    return ChatView(msgModel);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  width: 16,
                ),
                Expanded(
                    child: Padding(
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
                  child: TextField(
                    controller: _textFieldController,
                    onChanged: (_text) {
                      text = _text;
                    },
                    decoration: const InputDecoration(
                        border: OutlineInputBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(8)))),
                  ),
                )),
                TextButton(
                  onPressed: () {
                    if (_textFieldController.text.isEmpty) {
                      return;
                    }
                    TCPManager().sendMessage(text, model.userId);
                    ChatMessageModel msgModel = ChatMessageModel();
                    msgModel.context = text;
                    msgModel.uid = UserManager.getInstance()!.user!.uid;

                    ChatDataManager.getInstance()!
                        .addMessage(msgModel, model.user);
                    setState(() {
                      msgModels = ChatDataManager.getInstance()!
                          .getMsgModels(model.userId);
                      _textFieldController.text = "";
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: Colors.green,
                    backgroundColor: Colors.green,
                  ),
                  child: const Text(
                    "发送",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(
                  width: 16,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void scrollToBottom() {
    int microseconds = 1000;
    Timer(Duration(microseconds: microseconds), () {
      log("scrollToBottom");
      _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
    });
  }
}
