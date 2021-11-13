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

class Message {
  static Uuid uuid = const Uuid();

  int magicNumber = ProtocolConfig.MagicNumber;
  int version = ProtocolConfig.Version;
  int length = 0;
  int bodyEncode = BodyEncodeTypes.JSON;
  int uniqueId = 0;

  int bodyLength = 0;

  Message() {
    uniqueId = genUniqueId();
  }

  static int genUniqueId() {
    return uuid.v1().hashCode;
  }

  //消息类型 子类继承
  int getType() {
    return MessageTyps.UNDEF;
  }

  //默认实现 由子类继承
  ByteBuf encodeBody() {
    return ByteBuf.allocator();
  }

  int headerSize() {
    return 4 + 4 + 8 + 4 + 4 + 8;
  }

  //编码消息体为ByteBuf
  ByteBuf encode() {
    ByteBuf bodyBuf = encodeBody();
    length = headerSize() + bodyBuf.couldReadableSize;

    ByteBuf buf = ByteBuf.allocator(size: 1024);
    buf.writeInt32(magicNumber);
    buf.writeInt32(version);
    buf.writeInt64(length);
    buf.writeInt32(getType());
    buf.writeInt32(bodyEncode);
    buf.writeInt64(uniqueId);

    if (bodyBuf.hasReadContent) {
      buf.writeByteBuf(bodyBuf);
    }

    //buf.debugPrint();
    return buf;
  }
} //end class

