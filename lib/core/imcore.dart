import 'dart:io';
import 'dart:typed_data';

import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/login.dart';
import 'package:dearim/core/protocol/protocol.dart';

import 'protocol/message.dart';

///
/// IM服务网络收发
///
///

//客户端状态
enum State {
  unconnect, //未连接
  connecting, //连接中
  loging, //登录中
  logined, //登录成功
  unloging, //注销中
  undef, //未定义
}

enum DataStatus {
  errorMagicNumber, //协议解析错误
  errorVersion,
  errorBodyEncode,
  errorOther,
  errorLength, //数据长度不足
  success, //成功
}

//im登录回调
typedef IMLoginCallback = Function(Result result, int code);

//im注销回调
typedef IMLoginOutCallback = Function(Result result);

class IMClient {
  // static const String _serverAddress = "10.242.142.129"; //
  // static const String _serverAddress = "192.168.31.230"; //
  static const String _serverAddress = "192.168.31.37";

  static const int _port = 1013;

  static IMClient? _instance;

  static IMClient get instance => _instance ?? IMClient();

  static String get ServerAddress => _serverAddress;

  static int get Port => _port;

  //用户id
  int _uid = -1;

  //注册token
  String? _token;

  State _state = State.undef;

  IMLoginCallback? _loginCallback;

  Socket? _socket;

  ByteBuf _dataBuf = ByteBuf.allocator(); //

  final List _todoList = []; //缓存要发送的消息

  IMClient() {
    _state = State.unconnect;
    LogUtil.log("imclient instance create");
  }

  void debugStatus() {
    LogUtil.log("imclent state : $_state");
  }

  //im登录
  void imLogin(int uid, String token, {IMLoginCallback? loginCb}) {
    _uid = uid;
    _token = token;
    _loginCallback = loginCb;

    _socketConnect();
  }

  //im退出登录
  void imLoginOut(String token, {IMLoginOutCallback? loginOutCb}) {}

  //状态切换
  void _changeState(State newState) {
    if (_state != newState) {
      _state = newState;
    }
    LogUtil.log("state change : $_state");
  }

  //连接服务器socket
  void _socketConnect() {
    _changeState(State.connecting);

    Future<Socket> socketFuture = Socket.connect(ServerAddress, Port,
        timeout: const Duration(seconds: 20));

    socketFuture.then((socket) {
      LogUtil.log(
          "连接成功! server ${socket.remoteAddress} : ${socket.remotePort}");

      _socket = socket;

      //建立socket监听
      _socket?.listen((Uint8List data) {
        _receiveRemoteData(data);
      });

      if (_socket != null) {
        _onSocketFirstContected();
      }
    }).catchError((error) {
      LogUtil.errorLog("socket 连接失败 ${error.toString()}");
      _onSocketClose();
      _changeState(State.unconnect);
    }).whenComplete(() {
      _onSocketClose();
      _changeState(State.unconnect);
    });
  }

  //sokcet首次连接成功
  void _onSocketFirstContected() {
    //todo 发送请求登录消息
    IMLoginReqMessage loginReqMsg = IMLoginReqMessage(_uid, _token);
    _sendData(loginReqMsg.encode());
  }

  //socket被关闭
  void _onSocketClose() {}

  //接收到远端数据
  void _receiveRemoteData(Uint8List data) {
    ByteBuf recvBuf = ByteBuf.allocator(size: data.length);
    recvBuf.writeUint8List(data);
    LogUtil.log("received data  len : ${data.length}");
    //recvBuf.debugHexPrint();

    _dataBuf.writeByteBuf(recvBuf);
    _dataBuf.debugHexPrint();

    while (_dataBuf.hasReadContent) {
      final DataStatus checkResult =
          _checkDataStatus(_dataBuf.copy()); //使用备份来做检测

      if (checkResult == DataStatus.success) {
        final Message? msg = parseByteBufToMessage(_dataBuf);
        _dataBuf.compact();

        //hand
        _handleMsg(msg);
      } else if (checkResult == DataStatus.errorLength) {
        break;
      } else {
        // _socket?.close();
        break;
      }
    } //end while
  }

  //将原始数据解码成message
  Message? parseByteBufToMessage(ByteBuf buf) {
    Message msgHead = Message.fromBytebuf(buf);
    Message? result;
    switch (msgHead.type) {
      case MessageTyps.LOGIN_RESP:
        result = IMLoginRespMessage();
        result.decodeBody(buf, msgHead.bodyLength);
        break;
    }
    return result;
  }

  //针对不同message 做不同业务处理
  void _handleMsg(Message? msg) {
    MessageHandler? handler;

    switch (msg?.type) {
      case MessageTyps.LOGIN_RESP:
        handler = IMLoginRespHandler();
        break;
    }

    handler?.handle(this, msg);
  }

  //检测数据状态
  DataStatus _checkDataStatus(ByteBuf buf) {
    if (buf.couldReadableSize < Message.headerSize()) {
      return DataStatus.errorLength;
    }

    int magicNumber = buf.readInt32();
    if (magicNumber != ProtocolConfig.MagicNumber) {
      return DataStatus.errorMagicNumber;
    }

    int version = buf.readInt32();
    if (version != ProtocolConfig.Version) {
      return DataStatus.errorVersion;
    }

    int length = buf.readInt64();
    int lastLength = length - 16; //剩余长度
    if (buf.couldReadableSize < lastLength) {
      return DataStatus.errorLength;
    }

    buf.readInt32();
    int encodeType = buf.readInt32();
    if (encodeType != ProtocolConfig.BodyEncodeType) {
      return DataStatus.errorBodyEncode;
    }

    return DataStatus.success;
  }

  //发送数据
  void _sendData(ByteBuf buf) {
    LogUtil.log("send data size = ${buf.couldReadableSize}");
    buf.debugHexPrint();

    if (buf.couldReadableSize <= 0) {
      return;
    }
    // buf.debugPrint();

    _socket?.add(buf.readAllUint8List());
    _socket?.flush();
    //_socket?.writeAll(buf.readAllUint8List());
  }
} //end class

//handler抽象类
abstract class MessageHandler<T> {
  void handle(IMClient client, T msg);
}
