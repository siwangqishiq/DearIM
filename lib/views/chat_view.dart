// ignore_for_file: must_be_immutable, no_logic_in_create_state, constant_identifier_names

import 'dart:convert';
import 'dart:io';

import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/utils.dart';
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
    final String avatar = contactModel.avatar;
    final String heroId = "$avatar?${Utils.genUnique()}";
    
    List<Widget> children = [
      createImmessageView(),
      SizedBox(
        width: innerSpace,
      ),
      GestureDetector(
        onTap: () {
          //LogUtil.log("click $avatar");
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ExplorerImagePage(avatar , heroId: heroId))
          );
          // Navigator.of(context).push(
          //   PageRouteBuilder(
          //     pageBuilder: (BuildContext context, Animation<double> animation,
          //                   Animation<double> secondaryAnimation) {
          //       return ExplorerImagePage(avatar , heroId: heroId);
          //     },
          //   ),
          // );
        },
        child: Hero(
          tag: heroId,
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
              mainAxisAlignment:!isSendOutMsg ? MainAxisAlignment.start : MainAxisAlignment.end,
              children: children
            )
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

  //根据消息类型 创建消息视图
  Widget createImmessageView(){
    switch(msgModel.msgType){
      case MessageType.text:
        return _textMsgView();
      case MessageType.picture:
        return _imageMsgView();
      default:
        return const Text("未知消息");
    }//end switch
  }

  //文本消息
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

  //图片消息
  Widget _imageMsgView(){
    final IMMessage msg = msgModel.immessage!;

    //计算实际显示宽高
    String attachInfo = msg.attachInfo??"{}";
    var info = jsonDecode(attachInfo);
    var width = info["w"];
    var height = info["h"];
    Size imageSize = _calulateImageSize(width , height);

    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: imageSize.width,
        height: imageSize.height,
        color: Colors.green,
        child: msg.url == null?
          Image.file(File(msg.localPath!) , width: double.infinity , height: double.infinity , fit: BoxFit.fitWidth)
        :Image.network(msg.url!)
      )
    );
  }

  //计算image合适的显示大小
  Size _calulateImageSize(int width , int height){
    final double maxWidth = MediaQuery.of(context).size.width / 2.0;
    final double maxHeight = maxWidth * 1.5;
    final double ratio = width / height;//宽高比

    double newWidth = width.toDouble();
    double newHeight = height.toDouble();
    if(width >= height){//宽图
      newWidth = width >= maxWidth ?maxWidth:width.toDouble();
      newHeight = newWidth / ratio;
    }else{
      newHeight = height>= maxHeight?maxHeight:height.toDouble();
      newWidth = newHeight * ratio;
    }

    return Size(newWidth,newHeight);
  }
}
