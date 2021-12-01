// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'package:dearim/datas/chat_data.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/user/user.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/utils/timer_utils.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:dearim/views/head_view.dart';
import 'package:flutter/material.dart';

class ChatView extends StatefulWidget {
  ChatMessageModel msgModel;
  ChatView(this.msgModel, {Key? key}) : super(key: key);

  @override
  _ChatViewState createState() => _ChatViewState(msgModel);
}

class _ChatViewState extends State<ChatView> {
  ChatMessageModel msgModel = ChatMessageModel();
  _ChatViewState(this.msgModel);
  @override
  Widget build(BuildContext context) {
    bool isSelf = false;
    double space = 16;
    double innerSpace = 10;
    User? user = ChatDataManager.getInstance()!.getUser(msgModel.uid);
    if (msgModel.uid == UserManager.getInstance()!.user!.uid) {
      isSelf = true;
    }

    String avatar = isSelf ? UserManager.getInstance()!.user!.avatar : user!.avatar;

    List<Widget> children = [
      ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Container(
            constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width - 200),
            color: ColorThemes.themeColor,
            child: Padding(
              padding: EdgeInsets.all(innerSpace),
              child: Text(
                msgModel.context,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          )),
      SizedBox(
        width: innerSpace,
      ),
      HeadView(avatar , circle: 8 , width: 38 , height: 38, size:ImageSize.small),
      SizedBox(
        width: space,
      ),
    ];
    if (!isSelf) {
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
        ClipRRect(
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
        ),
        Column(
          children: [
            SizedBox(
              height: space,
            ),
            Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment:
                    !isSelf ? MainAxisAlignment.start : MainAxisAlignment.end,
                children: children)
          ],
        )
      ],
    );
  }
}
