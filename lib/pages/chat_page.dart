import 'dart:async';
import 'dart:developer';
import 'dart:ui';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/datas/chat_data.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/tcp/tcp_manager.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/views/chat_view.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:flutter/material.dart';

///
/// P2P聊天页
///
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
  List<ChatMessageModel> msgModels = [];
  final ScrollController _listViewController = ScrollController();

  IMMessageIncomingCallback? _msgIncomingCallback;

  @override
  void initState() {
    super.initState();
    msgModels.addAll(queryHistoryMessage());//查询历史消息

    _msgIncomingCallback = (incomingIMMessageList) {
      setState(() {
        receiveText = incomingIMMessageList.last.content;
        log(receiveText!);
        ChatMessageModel incomingMsgModel = ChatMessageModel.fromIMMessage(incomingIMMessageList.last);
        msgModels.add(incomingMsgModel);
      });
    };
    TCPManager().registerMessageCommingCallbck(_msgIncomingCallback!);
  }

  List<ChatMessageModel> queryHistoryMessage(){
    List<ChatMessageModel> result = <ChatMessageModel>[];
    var imMsgList = IMClient.getInstance().queryIMMessageList(IMMessageSessionType.P2P, model.userId);
    for(IMMessage imMsg in imMsgList){
      result.add(ChatMessageModel.fromIMMessage(imMsg));
    }//end for each
    return result;
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
                  itemCount: msgModels.length,
                  itemBuilder: (BuildContext context, int index) {
                    ChatMessageModel msgModel = msgModels[index];
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
                    maxLines: null,
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
                    var msg = TCPManager().sendMessage(text, model.userId);
                    if(msg == null){
                      return;
                    }
                    msgModels.add(ChatMessageModel.fromIMMessage(msg));
                    setState(() {
                      _textFieldController.text = "";
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.all(16.0),
                    primary: ColorThemes.themeColor,
                    backgroundColor: ColorThemes.themeColor,
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
            ),
            const SizedBox(
              height: 16,
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

  @override
  void dispose() {
    if(_msgIncomingCallback != null){
      TCPManager().unregistMessageCommingCallback(_msgIncomingCallback!);
    }
    super.dispose();
  }
}
