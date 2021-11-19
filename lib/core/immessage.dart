import 'dart:io';

import 'package:dearim/core/protocol/message.dart';

///
/// IM消息
///
// ignore_for_file: constant_identifier_names

//im消息体
class IMMessage{
  int size = 0;//消息总大小
  String msgId = "";//消息唯一标识
  int from = 0;//发送人ID
  int to = 0;//接收人ID
  int createTime = 0;
  int updateTime =0;

  int imMsgType = 0;//消息类型
  int sessionType = IMMessageSessionType.P2P;
  int msgState = 0;//消息状态
  int readState = 0;//已读状态
  int fromClient = 0;
  int toClient = 0;

  String? content;//消息内容
  String? url;//资源Url  
  int attachState = 0;//附件状态
  String? attachInfo;//附件信息
  String? localPath;//资源本地路径
  String? custom;//自定义扩展字段

  IMMessage();

  factory IMMessage.fromMap(Map<String , dynamic> map){
    final IMMessage msg = IMMessage();
    msg.size = map["size"]??0;
    msg.msgId = map["msgId"];
    msg.from = map["from"]??0;
    msg.to = map["to"]??0;
    msg.createTime = map["createTime"]??0;
    msg.updateTime = map["updateTime"]??0;

    msg.imMsgType = map["imMsgType"]??0;
    msg.sessionType = map["sessionType"]??0;
    msg.msgState = map["msgState"]??0;
    msg.readState = map["readState"]??0;
    msg.fromClient = map["fromClient"]??0;
    msg.toClient = map["toClient"]??0;

    msg.createTime = map["content"];
    msg.url = map["url"];
    msg.attachState = map["attachState"]??0;
    msg.attachInfo = map["attachInfo"];
    msg.custom = map["custom"];
    
    return msg;
  }

  //encode编码为Map
  Map<String , dynamic> endcodeMap(){
    final Map<String,dynamic> body = <String , dynamic>{};
    body["size"] = size;
    body["msgId"] = msgId;
    body["from"] = from;
    body["to"] = to;
    body["createTime"] = createTime;
    body["updateTime"] = updateTime;
  
    body["imMsgType"] = imMsgType;
    body["sessionType"] = sessionType;
    body["msgState"] = msgState;
    body["readState"] = readState;
    body["fromClient"] = fromClient;
    body["toClient"] = toClient;

    body["content"] = content;
    body["url"] = url;
    body["attachState"] = attachState;
    body["attachInfo"] = attachInfo;
    body["custom"] = custom;

    return body;
  }
  
}//end class

class IMMessageType{
  static const int Text = 1;//文本消息
}

class IMMessageSessionType{
  static const int P2P = 1;
  static const int TEAM = 2;
}

class ClientType{
  static const int Windows = 1;
  static const int Macos = 2;
  static const int Linux = 3;
  static const int Web = 4;
  static const int Android = 5;
  static const int Ios = 6;
}

//IM消息返回结果
class IMMessageResult extends Result{
  int createTime = 0;
  int updateTime = 0;
  String? msgId;
}

//构造消息体
class IMMessageBuilder{

  //创建文本消息
  static IMMessage createText(int toUid , int sessionType , String content){
    IMMessage imMessage = IMMessage();

    imMessage.to = toUid;
    imMessage.fromClient = getClientType();
    imMessage.sessionType = sessionType;
    imMessage.imMsgType = IMMessageType.Text;
    imMessage.content = content;
    return imMessage;
  }

  static int getClientType(){
    if(Platform.isAndroid){
      return ClientType.Android;
    }else if(Platform.isIOS){
      return ClientType.Ios;
    }else if(Platform.isWindows){
      return ClientType.Windows;
    }else if(Platform.isLinux){
      return ClientType.Linux;
    }else if(Platform.isMacOS){
      return ClientType.Macos;
    }

    return ClientType.Web;
  }
}//end class




