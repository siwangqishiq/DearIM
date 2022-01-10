// ignore_for_file: must_be_immutable, no_logic_in_create_state, constant_identifier_names

import 'package:dearim/core/log.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/pages/explorer_image.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/utils/timer_utils.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:dearim/views/head_view.dart';
import 'package:dearim/widget/emoji.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  ChatMessageModel msgModel;
  ChatMessageModel? preMsgModel;
  ChatView(this.msgModel, {this.preMsgModel , Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState(msgModel);
}

class _ChatViewState extends State<ChatView> {
  late ChatMessageModel msgModel;
  final double space = 8;
  final double innerSpace = 10;

  _ChatViewState(this.msgModel);

  @override
  Widget build(BuildContext context) {
    
    bool isSendOutMsg = !msgModel.isReceived;
    
    int uid = msgModel.isReceived?(msgModel.sessionId):(UserManager.getInstance()?.user?.uid??0);
    final ContactModel contactModel = ContactsDataCache.instance.getContact(uid)??ContactModel("",0);
    String avatar = contactModel.avatar;
    
    List<Widget> children = [
      createImmessageView(),
      SizedBox(
        width: innerSpace,
      ),
      GestureDetector(
        onTap: (){
          //LogUtil.log("click $avatar");
          Navigator.of(context).push(
            PageRouteBuilder(
              pageBuilder: (BuildContext context, Animation<double> animation,
                            Animation<double> secondaryAnimation) {
                return ExplorerImagePage(avatar);
              },
            ),
          );
        },
        child: Hero(
          tag: avatar,
          child: HeadView(avatar , circle: 8 , width: 38 , height: 38, size:ImageSize.small),
        ),
      ),
      SizedBox(
        width: space,
      ),
    ];
    if (!isSendOutMsg) {
      List<Widget> reverses = [];
      for (var i = children.length - 1; i >= 0; i--) {
        reverses.add(children[i]);
      }
      children = reverses;
    }

    String time = TimerUtils.getMessageFormatTime(msgModel.updateTime);
    return Column(
      children: [
        SizedBox(
          height: space,
        ),
        Visibility(
          visible: isTimeVisible(),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              color: ColorThemes.unselectColor,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(5, 3, 5, 3),
                child: Text(
                  time,
                  style: const TextStyle(fontSize: 12, color: Colors.white),
                ),
              ),
            ),
          ) 
        ),
        Column(
          children: [
            SizedBox(
              height: space,
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    !isSendOutMsg ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: children)
          ],
        )
      ],
    );
  }

  //根据时间差 判断时间控件是否显示
  bool isTimeVisible(){
    if(widget.preMsgModel == null){
      return true;
    }

    const int MSG_MAX_TIME_DURING_MILLS = 5 * 60 * 1000;

    ChatMessageModel preModel = widget.preMsgModel!;
    ChatMessageModel currentModel = widget.msgModel;
    
    if((preModel.updateTime - currentModel.updateTime).abs() < MSG_MAX_TIME_DURING_MILLS){
      return false;
    }
    return true;
  }

  Widget createImmessageView(){
    switch(msgModel.msgType){
      case MessageType.text:
        return _textMsgView();
      case MessageType.picture:
        return const Text("图片消息");
      default:
        return const Text("未知消息");
    }//end switch
  }


  Widget _textMsgView(){
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width - 200),
        color: ColorThemes.themeColor,
        child: Padding(
          padding: EdgeInsets.all(innerSpace),
          child: EmojiText(
            msgModel.content,
            style: const TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      )
    );
  }
}
