import 'dart:convert';
import 'dart:typed_data';
import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import '../utils.dart';
import 'message.dart';
import 'protocol.dart';

//登录请求
class IMLoginReqMessage extends Message {
  int? uid;
  String? token;

  IMLoginReqMessage(this.uid, this.token);

  @override
  ByteBuf encodeBody() {
    Map body = {};
    body["uid"] = uid;
    body["token"] = token;

    String jsonBody = jsonEncode(body);
    LogUtil.log("jsonBody:$jsonBody");

    Uint8List bodyData = Utils.convertStringToUint8List(jsonBody);

    ByteBuf bodyBuf = ByteBuf.allocator(size: bodyData.length);
    bodyBuf.writeUint8List(bodyData);
    return bodyBuf;
  }

  @override
  int getType() {
    return MessageTyps.LOGIN_REQ;
  }
} //end class

class IMLoginRespMessage extends Message {

  factory IMLoginRespMessage.from(Message head, ByteBuf buf) {
    IMLoginRespMessage respMessage = IMLoginRespMessage();
    respMessage.fill(head);
    respMessage.decodeBody(buf, respMessage.bodyLength);
    return respMessage;
  }

  Result? _result;

  Result? get result => _result;

  @override
  dynamic decodeBody(ByteBuf buf, int bodySize) {
    Uint8List rawData = buf.readUint8List(bodySize);

    String originJsonStr = Utils.convertUint8ListToString(rawData);
    LogUtil.log(originJsonStr);

    try{
      var jsonMap = jsonDecode(Utils.convertUint8ListToString(rawData));
    
      _result = Result();
      _result?.code = jsonMap["code"]??0;
      _result?.result = jsonMap["result"];
      _result?.reason = jsonMap["reason"];
    }catch(e){
      LogUtil.errorLog(e.toString());
    }
    return _result;
  }
  
  IMLoginRespMessage();
}

//处理
class IMLoginRespHandler extends MessageHandler<IMLoginRespMessage> {
  @override
  void handle(IMClient client, IMLoginRespMessage msg) {
    LogUtil.log("handle login resp unique ${msg.uniqueId} ");
    //todo

    if(msg.result != null && msg.result!.result){
      client.onLoginSuccess();
    }

    //callback
    client.loginCallback!(msg.result!);
  }
}//end IMLoginRespHandler class
