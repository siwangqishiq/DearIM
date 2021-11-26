// ignore_for_file: must_be_immutable, no_logic_in_create_state

import 'package:dearim/models/chat_message_model.dart';
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
    return const Text("data");
  }
}
