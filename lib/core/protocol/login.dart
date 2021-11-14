import 'dart:convert';
import 'dart:typed_data';
import 'package:dearim/core/byte_buffer.dart';
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
}//end class
