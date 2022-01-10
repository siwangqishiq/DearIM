import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';

enum MessageType {
  text,
  picture,
  share,
  unknow
}


class ChatMessageModel {
  int uid = 0;
  String content = "";
  int updateTime = 0;
  MessageType msgType = MessageType.text;
  bool isReceived = false;//是否是消息的接收者
  int sessionId = 0;//会话ID
  
  ChatMessageModel();

  
  static MessageType typeOf(int type){
    if(type == IMMessageType.Text){
      return MessageType.text;
    }else if(type == IMMessageType.Image){
      return MessageType.picture;
    }
    return MessageType.unknow;
  }

  factory ChatMessageModel.fromIMMessage(IMMessage msg){
    ChatMessageModel model = ChatMessageModel();

    model.isReceived = msg.isReceived;
    model.sessionId = msg.isReceived?msg.fromId:msg.toId;
    model.content = msg.content??"";
    model.updateTime = msg.updateTime;
    model.msgType = typeOf(msg.imMsgType);
    //LogUtil.log("messageTyep ${msg.imMsgType} ");
    return model;
  }
}
