import 'dart:convert';
import 'dart:typed_data';

import '../byte_buffer.dart';
import '../imcore.dart';
import '../immessage.dart';
import '../log.dart';
import '../utils.dart';
import 'message.dart';
import 'protocol.dart';

///
///
///
class PushIMMessageReqMsg extends Message {
  IMMessage? imMessage;

  factory PushIMMessageReqMsg.from(Message head, ByteBuf buf) {
    PushIMMessageReqMsg imMessageReqMsg = PushIMMessageReqMsg();
    imMessageReqMsg.fill(head);
    imMessageReqMsg.decodeBody(buf, imMessageReqMsg.bodyLength);
    return imMessageReqMsg;
  }

  PushIMMessageReqMsg();

  @override
  dynamic decodeBody(ByteBuf buf, int bodySize) {
    Uint8List rawData = buf.readUint8List(bodySize);
    
    String originJsonStr = Utils.convertUint8ListToString(rawData);
    LogUtil.log(originJsonStr);

    try{
      var jsonMap = jsonDecode(originJsonStr);
      imMessage = IMMessage.fromMap(jsonMap);
    }catch(e){
      LogUtil.errorLog(e.toString());
    }
    return imMessage;
  }

  @override
  int getType() {
    return MessageTypes.PUSH_IMMESSAGE_REQ;
  }
} //end class

///
/// PushIMMessageHandler处理
///
class PushIMMessageHandler extends MessageHandler<PushIMMessageReqMsg> {
  @override
  void handle(IMClient client, PushIMMessageReqMsg msg) {
    LogUtil.log("send immessage resp unique(${msg.uniqueId}) ");

    if(msg.imMessage == null){
      return;
    }

    IMMessage imMessage = msg.imMessage!;
    LogUtil.log("received msg ${imMessage.content}");
    
    List<IMMessage> incomingIMList = <IMMessage>[];
    imMessage.isReceived = true;//是接收到的消息

    incomingIMList.add(imMessage);

    client.receivedIMMessage(incomingIMList);
  }
}//end class

///
///发送消息返回
///
// class PushIMMessageRespMsg extends Message{

//   SendIMMessageRespMsg();



//   IMMessageResult? result;

//   @override
//   dynamic decodeBody(ByteBuf buf, int bodySize) {
//     Uint8List rawData = buf.readUint8List(bodySize);
    
//     String originJsonStr = Utils.convertUint8ListToString(rawData);
//     LogUtil.log(originJsonStr);

//     try{
//       var jsonMap = jsonDecode(Utils.convertUint8ListToString(rawData));
      
//       result = IMMessageResult();
//       result?.code = jsonMap["code"]??0;
//       result?.result = jsonMap["result"];
//       result?.reason = jsonMap["reason"];

//       result?.createTime = jsonMap["createTime"];
//       result?.updateTime = jsonMap["updateTime"];
//       result?.msgId = jsonMap["msgId"];
//     }catch(e){
//       LogUtil.errorLog(e.toString());
//     }
//     return result;
//   }

//   @override
//   int getType() {
//     return MessageTypes.SEND_IMMESSAGE_RESP;
//   }
// }


