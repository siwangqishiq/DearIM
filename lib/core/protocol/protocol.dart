//消息类型
import 'package:dearim/core/byte_buffer.dart';
import 'package:uuid/uuid.dart';

class MessageTyps {
  static const int UNDEF = 0;
  static const int LOGIN_REQ = 1; //登录请求
  static const int LOGIN_RESP = 2; //登录返回
}

class BodyEncodeTypes {
  static const int JSON = 1;
}

class ProtocolConfig {
  static const int MagicNumber = 100; //yoki
  static const int Version = 1;
}

