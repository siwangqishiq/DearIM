import 'package:dearim/core/immessage.dart';

enum MessageType {
  text,
  share,
  picture,
}

class ChatMessageModel {
  int uid = 0;
  String content = "";
  int updateTime = 0;
  MessageType msgType = MessageType.text;
  bool isReceived = false;//是否是消息的接收者
  int sessionId = 0;//会话ID

  ChatMessageModel();

  factory ChatMessageModel.fromIMMessage(IMMessage msg){
    ChatMessageModel model = ChatMessageModel();
    
    model.isReceived = msg.isReceived;
    model.sessionId = msg.isReceived?msg.fromId:msg.toId;
    model.content = msg.content??"";
    model.updateTime = msg.updateTime;
    
    return model;
  }
}
