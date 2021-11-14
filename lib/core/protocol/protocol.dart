//消息类型
class MessageTyps {
  static const int UNDEF = 0;
  static const int LOGIN_REQ = 1; //登录请求
  static const int LOGIN_RESP = 2; //登录返回
}

class BodyEncodeTypes {
  static const int JSON = 1;
}

class ProtocolConfig {
  static const int MagicNumber = 900523; //
  static const int Version = 1;
  static const int BodyEncodeType = BodyEncodeTypes.JSON;
}

class Codes {
  static const int success = 200; //
  static const int error = 500;
}
