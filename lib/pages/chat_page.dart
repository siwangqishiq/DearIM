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
import 'package:dearim/views/chat_keyboard.dart';
import 'package:dearim/views/chat_view.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:dearim/views/emogy_pan.dart';
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

  List<GridItemModel> itemModels = [
    GridItemModel(
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202011%2F17%2F20201117105437_45d41.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641181068&t=e25de9b298f05382538b02439d459a4f",
        "name"),
    GridItemModel(
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202011%2F17%2F20201117105437_45d41.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641181068&t=e25de9b298f05382538b02439d459a4f",
        "name"),
    GridItemModel(
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202011%2F17%2F20201117105437_45d41.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641181068&t=e25de9b298f05382538b02439d459a4f",
        "name"),
    GridItemModel(
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202011%2F17%2F20201117105437_45d41.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641181068&t=e25de9b298f05382538b02439d459a4f",
        "name"),
    GridItemModel(
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202011%2F17%2F20201117105437_45d41.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641181068&t=e25de9b298f05382538b02439d459a4f",
        "name"),
    GridItemModel(
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202011%2F17%2F20201117105437_45d41.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641181068&t=e25de9b298f05382538b02439d459a4f",
        "name"),
    GridItemModel(
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202011%2F17%2F20201117105437_45d41.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641181068&t=e25de9b298f05382538b02439d459a4f",
        "name"),
    GridItemModel(
        "https://gimg2.baidu.com/image_search/src=http%3A%2F%2Fc-ssl.duitang.com%2Fuploads%2Fblog%2F202011%2F17%2F20201117105437_45d41.thumb.1000_0.jpeg&refer=http%3A%2F%2Fc-ssl.duitang.com&app=2002&size=f9999,10000&q=a80&n=0&g=0n&fmt=jpeg?sec=1641181068&t=e25de9b298f05382538b02439d459a4f",
        "name"),
  ];

  _ChatPageState(this.model);
  String text = "";
  String? receiveText = "";
  List<ChatMessageModel> msgModels = [];
  final ScrollController _listViewController = ScrollController();

  IMMessageIncomingCallback? _msgIncomingCallback;
  // ignore: prefer_final_fields
  TextEditingController _textFieldController = TextEditingController();
  FocusNode _focusNode = FocusNode();
  bool showBottomAction = false;
  bool showemoji = false;
  @override
  void initState() {
    super.initState();
    msgModels.addAll(queryHistoryMessage()); //查询历史消息

    _msgIncomingCallback = (incomingIMMessageList) {
      IMMessage incomingMessage = incomingIMMessageList.last;
      if (incomingMessage.sessionId != model.userId) {
        //不属于此会话的消息 不做处理
        return;
      }
      if (incomingMessage.sessionId == UserManager.getInstance()!.user!.uid) {
        //本人发给本人的消息的消息 不做处理
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

  List<ChatMessageModel> queryHistoryMessage() {
    List<ChatMessageModel> result = <ChatMessageModel>[];
    var imMsgList = IMClient.getInstance()
        .queryIMMessageList(IMMessageSessionType.P2P, model.userId);
    for (IMMessage imMsg in imMsgList) {
      result.add(ChatMessageModel.fromIMMessage(imMsg));
    } //end for each
    return result;
  }

  @override
  Widget build(BuildContext context) {
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
                    return ChatView(msgModel , preMsgModel: index - 1 >=0?msgModels[index - 1]:null,);
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
                      onSubmitted: (text) {
                        sendMsg(text);
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
                // Container(
                //   width: 40,
                //   height: 40,
                //   child: TextButton(
                //     onPressed: () {
                //       setState(() {
                //         showemoji = !showemoji;
                //         showBottomAction = false;
                //       });
                //     },
                //     child: const Icon(Icons.sentiment_satisfied_alt),
                //   ),
                // ),
                // Container(
                //   width: 40,
                //   height: 40,
                //   child: TextButton(
                //     onPressed: () {
                //       setState(() {
                //         showBottomAction = !showBottomAction;
                //         showemoji = false;
                //       });
                //     },
                //     child: const Icon(Icons.send),
                //   ),
                // ),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(fixedSize:const Size(60 ,40)),
                  onPressed: () => sendMsg(text),
                  child:const Text("发送" , style: TextStyle(color: Colors.white)),
                ),
                const SizedBox(
                  width: 16,
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Visibility(
              visible: showemoji,
              child: EmojiPanView(),
            ),
            Visibility(
              visible: showBottomAction,
              child: ChatKeyboard(itemModels),
            ),
          ],
        ),
      ),
    );
  }

  void sendMsg(String text) {
    if (_textFieldController.text.isEmpty) {
      return;
    }
    var msg = TCPManager().sendMessage(text, model.userId);
    if (msg == null) {
      return;
    }
    msgModels.add(ChatMessageModel.fromIMMessage(msg));
    setState(() {
      _textFieldController.text = "";
    });
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
    if (_msgIncomingCallback != null) {
      TCPManager().unregistMessageCommingCallback(_msgIncomingCallback!);
    }
    super.dispose();
  }
}
