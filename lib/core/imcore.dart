import 'dart:io';
import 'dart:typed_data';

import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/login.dart';

///
/// IM服务网络收发
///
///

//接口执行结果
enum Result { success, failed }

//客户端状态
enum State {
  unconnect, //未连接
  connecting, //连接中
  loging, //登录中
  logined, //登录成功
  unloging, //注销中
  undef, //未定义
}

//im登录回调
typedef IMLoginCallback = Function(Result result, int code);

//im注销回调
typedef IMLoginOutCallback = Function(Result result);

class IMClient {
  // static const String _serverAddress = "10.242.142.129"; //
  static const String _serverAddress = "192.168.31.230"; //

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
    LogUtil.log("received data  len : ${data.length}");
  }

  //发送数据
  void _sendData(ByteBuf buf) {
    LogUtil.log("send data size = ${buf.couldReadableSize}");
    if (buf.couldReadableSize <= 0) {
      return;
    }
    // buf.debugPrint();

    _socket?.add(buf.readAllUint8List());
    _socket?.flush();
    //_socket?.writeAll(buf.readAllUint8List());
  }
} //end class
