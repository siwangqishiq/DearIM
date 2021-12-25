import 'dart:async';
import 'dart:developer';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/tcp/tcp_manager.dart';
import 'package:dearim/views/chat_view.dart';
import 'package:flutter/material.dart';

///
/// P2P聊天页
///
class ChatPage extends StatefulWidget {
  final ContactModel model;

  const ChatPage(this.model, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage>{
  late List<ChatMessageModel> msgModels = [];
  final ScrollController _listViewController = ScrollController();
  String? receiveText = "";
  IMMessageIncomingCallback? _msgIncomingCallback;

  late InputPanelWidget inputPanelWidget;
  
  @override
  void initState() {
    super.initState();
    initMessageList();
    inputPanelWidget = InputPanelWidget(this);    
  }

    //查询历史消息
  List<ChatMessageModel> queryHistoryMessage() {
    List<ChatMessageModel> result = <ChatMessageModel>[];
    var imMsgList = IMClient.getInstance()
          .queryIMMessageList(IMMessageSessionType.P2P, widget.model.userId);
    for (IMMessage imMsg in imMsgList) {
      result.add(ChatMessageModel.fromIMMessage(imMsg));
    } //end for each
    return result;
  }

  void initMessageList(){
    msgModels.addAll(queryHistoryMessage()); //查询历史消息
    _msgIncomingCallback = (incomingIMMessageList) {
      IMMessage incomingMessage = incomingIMMessageList.last;

      if (incomingMessage.sessionId != widget.model.userId) {
        //不属于此会话的消息 不做处理
        return;
      }

      setState(() {
        receiveText = incomingIMMessageList.last.content;
        log(receiveText!);
        ChatMessageModel incomingMsgModel =
            ChatMessageModel.fromIMMessage(incomingIMMessageList.last);
        msgModels.add(incomingMsgModel);
      });
    };
    TCPManager().registerMessageCommingCallbck(_msgIncomingCallback!);
  }

  @override
  Widget build(BuildContext context) {
    scrollToBottom();
    
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.model.name,
          style: const TextStyle(color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                child: ListView.builder(
                  controller: _listViewController,
                  itemCount: msgModels.length,
                  itemBuilder: (BuildContext context, int index) {
                    ChatMessageModel msgModel = msgModels[index];
                    return ChatView(msgModel , preMsgModel: index - 1 >=0?msgModels[index - 1]:null,);
                  },
                ),
              ),
            ),
            const SizedBox(
              height: 16,
            ),
            inputPanelWidget,
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  void scrollToBottom() {
    int microseconds = 1000;
    Timer(Duration(microseconds: microseconds), () {
      _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
    });
  }

  @override
  void dispose() {
    if (_msgIncomingCallback != null) {
      TCPManager().unregistMessageCommingCallback(_msgIncomingCallback!);
    }
    super.dispose();
  }
}

///
/// 输入面板
///
class InputPanelWidget extends StatefulWidget{
  final ChatPageState chatPageContext;

  const InputPanelWidget(this.chatPageContext , {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InputPanelState();
  }
}

class InputPanelState extends State<InputPanelWidget>{
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _textFieldController = TextEditingController();
  String text = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 16,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: TextField(
              onSubmitted: (text) {
                sendTextIMMsg(text);
              },
              textInputAction: TextInputAction.send,
              maxLines: null,
              controller: _textFieldController,
              focusNode: _focusNode,
              onChanged: (_text) {
                text = _text;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        
        ElevatedButton(
          style: ElevatedButton.styleFrom(fixedSize:const Size(60 ,40)),
          onPressed: () => sendTextIMMsg(text),
          child:const Text("发送" , style: TextStyle(color: Colors.white)),
        ),
        const SizedBox(
          width: 16,
        ),
      ],
    );
  }

  //发送文本消息
  void sendTextIMMsg(String content){
    var model = widget.chatPageContext.widget.model;

    if (_textFieldController.text.isEmpty) {
      return;
    }
    
    var msg = TCPManager().sendMessage(text, model.userId);
    if (msg == null) {
      return;
    }

    var msgList = widget.chatPageContext.msgModels;
    msgList.add(ChatMessageModel.fromIMMessage(msg));

    setState(() {
      _textFieldController.text = "";
    });

    //refresh message list
    widget.chatPageContext.setState(() {
    });
  }
}

