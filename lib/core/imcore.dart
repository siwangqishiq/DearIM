// ignore_for_file: non_constant_identifier_names

import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/heart_beat_message.dart';
import 'package:dearim/core/protocol/login.dart';
import 'package:dearim/core/protocol/protocol.dart';
import 'package:dearim/core/protocol/push_immessage.dart';
import 'package:dearim/core/protocol/send_immessage.dart';
import 'package:dearim/core/session.dart';
import 'package:dearim/core/utils.dart';

import 'device.dart';
import 'log.dart';
import 'heart_beat.dart';
import 'protocol/kickoff.dart';
import 'protocol/logout.dart';
import 'protocol/message.dart';
import 'reconnect.dart';

///
/// IM服务
///
///

//客户端状态
enum ClientState {
  unconnect, //未连接
  connecting, //连接中
  unlogin, //已连接 但未登录
  loging, //登录中
  logined, //登录成功
  logouting, //注销中
  undef, //未定义
}

enum DataStatus {
  errorMagicNumber, //协议解析错误
  errorVersion, //版本错误
  errorBodyEncode, //消息体编码方式不兼容
  errorOther, //其他错误
  errorLength, //数据长度不足
  success, //成功
}

//im登录回调
typedef IMLoginCallback = Function(Result loginResult);

//im注销回调
typedef IMLogOutCallback = Function(Result result);

//发送IM消息 回调
typedef SendIMMessageCallback = Function(IMMessage imMessage, Result result);

//状态改变回调
typedef StateChangeCallback = Function(
    ClientState oldState, ClientState newState);

//被踢出事件回调
typedef KickoffCallback = Function();

//接收到新消息
typedef IMMessageIncomingCallback = Function(
    List<IMMessage> incomingIMMessageList);

//handler抽象类
abstract class MessageHandler<T> {
  void handle(IMClient client, T msg);
}

class IMClient {
  // static String _serverAddress = "10.242.142.129"; //
  // static const String _serverAddress = "192.168.31.230"; //
  static String _serverAddress = "192.168.31.37";
  // static String _serverAddress = "panyi.xyz";

  static int _port = 1013;

  static IMClient? _instance;

  static String get ServerAddress => _serverAddress;

  static int get Port => _port;

  IMLoginCallback? get loginCallback => _loginCallback;

  IMLogOutCallback? get logoutCallback => _logoutCallback;

  int get uid => _uid;

  ClientState get state => _state;

  Reconnect get reconnect => _reconnect;

  KickoffCallback? get kickoffCallback => _kickoffCallback;

  Map<String, SendIMMessageCallback> get sendIMMessageCallbackMap =>
      _sendIMMessageCallbackMap;

  //用户id
  int _uid = -1;

  //注册token
  String? _token;

  ClientState _state = ClientState.undef;

  IMLoginCallback? _loginCallback;

  IMLogOutCallback? _logoutCallback;

  KickoffCallback? _kickoffCallback;

  Socket? _socket;

  int _receivedPacketCount = 0;

  bool _loginIsManual = false; //记录是否是手动发起的登录

  SessionManager? _sessionManager;

  //发送IM消息回调
  final Map<String, SendIMMessageCallback> _sendIMMessageCallbackMap =
      <String, SendIMMessageCallback>{};

  final List<IMMessageIncomingCallback> _imMessageIncomingCallbackList =
      <IMMessageIncomingCallback>[];

  final ByteBuf _dataBuf = ByteBuf.allocator(); //

  final List<StateChangeCallback> _stateChangeCallbackList =
      <StateChangeCallback>[];

  //final List _todoList = []; //缓存要发送的消息

  late HeartBeat _heartBeat; //心跳包管理

  late Reconnect _reconnect; //断线重连

  late final StreamSubscription<ConnectivityResult> _streamSubscription;

  IMClient() {
    DeviceManager.getDevice();

    _state = ClientState.unconnect;
    LogUtil.log("imclient instance create");

    _streamSubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      LogUtil.log("网络环境变化$result");

      if (result == ConnectivityResult.none) {
        //网络不可用时
        onSocketClose();
      }
    });
    _heartBeat = HeartBeat(this);
    _reconnect = Reconnect(this);
  }

  static IMClient getInstance() {
    _instance ??= IMClient();
    return _instance!;
  }

  void debugStatus() {
    LogUtil.log("imclent state : $_state");
  }

  //im登录
  void imLogin(int uid, String token,
      {IMLoginCallback? loginCallback,
      String? host,
      int? port,
      bool manual = true}) {
    if (_state == ClientState.loging) {
      loginCallback?.call(Result.Error("正在登录中 请稍后再试"));
      return;
    }

    if (host != null) {
      _serverAddress = host;
    }

    if (port != null) {
      _port = port;
    }

    _uid = uid;
    _token = token;
    _loginCallback = loginCallback;
    _loginIsManual = manual;

    _socketConnect();
  }

  //im退出登录
  void imLoginOut({IMLogOutCallback? loginOutCallback}) {
    _logoutCallback = loginOutCallback;

    if (_state == ClientState.logined) {
      //已经登录的 才能退出登录
      final LogoutReqMessage logoutReq = LogoutReqMessage(_token);
      sendData(logoutReq.encode());
      _changeState(ClientState.logouting);
    } else {
      if (_logoutCallback != null) {
        _logoutCallback!(Result.Error("Current state is not logined"));
      }
      return;
    }
  }

  //发送IM消息
  void sendIMMessage(IMMessage imMessage, {SendIMMessageCallback? callback}) {
    imMessage.fromId = _uid;
    if (Utils.isTextEmpty(imMessage.msgId)) {
      imMessage.msgId = Utils.genUniqueMsgId();
    }

    if (_state != ClientState.logined) {
      callback?.call(imMessage, Result.Error("error im client stauts"));
      return;
    }

    var time = Utils.currentTime();
    imMessage.createTime = time;
    imMessage.updateTime = time;

    if (callback != null) {
      _sendIMMessageCallbackMap[imMessage.msgId] = callback;
    }

    //发送
    sendData(SendIMMessageReqMsg(imMessage).encode());

    _sessionManager?.updateRecentSession(imMessage);
  }

  //注册 或 解绑 状态改变事件监听
  bool registerStateObserver(StateChangeCallback callback, bool register) {
    if (register) {
      //注册
      if (!Utils.listContainObj(_stateChangeCallbackList, callback)) {
        _stateChangeCallbackList.add(callback);
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_stateChangeCallbackList, callback)) {
        _stateChangeCallbackList.remove(callback);
        return true;
      }
    }
    return false;
  }

  //注册最近会话变化监听
  bool registerRecentSessionObserver(
      RecentSessionChangeCallback callback, bool register) {
    return _sessionManager?.registerStateObserver(callback, register) ?? false;
  }

  //获取最近会话列表
  List<RecentSession> findRecentSessionList() {
    return _sessionManager?.findRecentSessionList() ?? [];
  }

  //注册接收IM消息
  bool registerIMMessageIncomingObserver(
      IMMessageIncomingCallback callback, bool register) {
    if (register) {
      //注册
      if (!Utils.listContainObj(_imMessageIncomingCallbackList, callback)) {
        _imMessageIncomingCallbackList.add(callback);
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_imMessageIncomingCallbackList, callback)) {
        _imMessageIncomingCallbackList.remove(callback);
        return true;
      }
    }
    return false;
  }

  void dispose() {
    _heartBeat.dispose();
    _reconnect.dispose();

    _sessionManager?.dispose();
    _streamSubscription.cancel();
  }

  //接收到新IM消息
  void receivedIMMessage(List<IMMessage> receivedMessageList) {
    for (IMMessage msg in receivedMessageList) {
      _sessionManager?.updateRecentSession(msg);
    } //end for each

    _fireMmMessageIncomingCallback(receivedMessageList);
  }

  void _fireMmMessageIncomingCallback(List<IMMessage> receivedMessageList) {
    for (IMMessageIncomingCallback callback in _imMessageIncomingCallbackList) {
      callback.call(receivedMessageList);
    } //end for each
  }

  //状态切换
  void _changeState(ClientState newState) {
    if (_state != newState) {
      final ClientState oldState = _state;
      _state = newState;
      //LogUtil.log("state change : $_state");
      _fireStateChangeCallback(oldState, _state);
    }
  }

  //触发状态改变回调
  void _fireStateChangeCallback(ClientState oldState, ClientState newState) {
    // LogUtil.log(
    //     "_stateChangeCallbackList size ${_stateChangeCallbackList.length} ${_stateChangeCallbackList.hashCode.hashCode}");
    for (StateChangeCallback cb in _stateChangeCallbackList) {
      cb(oldState, newState);
    }
  }

  //连接服务器socket
  void _socketConnect() {
    _socket?.destroy();
    _heartBeat.stopHeartBeat(); //停止心跳 重新开始

    _changeState(ClientState.connecting);

    Future<Socket> socketFuture = Socket.connect(ServerAddress, Port,
        timeout: const Duration(seconds: 20));

    socketFuture.then((socket) {
      LogUtil.log(
          "连接成功! remote ${socket.remoteAddress.host} : ${socket.remotePort}");

      _socket = socket;

      //建立socket监听
      _socket?.listen((Uint8List data) {
        _receiveRemoteData(data);
      }, onError: (err) {
        LogUtil.log("socket read error : ${err.toString()}");
        onSocketClose();
      }, onDone: () {
        LogUtil.log("socket remote closed");
        onSocketClose();
      });

      _changeState(ClientState.unlogin);

      if (_socket != null) {
        _onSocketFirstContected();
      }
    }).catchError((error) {
      LogUtil.errorLog("socket 连接失败 ${error.toString()}");
      onSocketClose();
      _changeState(ClientState.unconnect);
    }).onError((error, stackTrace) {
      LogUtil.log("occur error ${error.toString()}");
    }).whenComplete(() {
      //LogUtil.log("whenComplete");
    });
  }

  //socket首次连接成功
  void _onSocketFirstContected() {
    //todo 发送请求登录消息
    IMLoginReqMessage loginReqMsg = IMLoginReqMessage(_uid, _token);
    loginReqMsg.manual = _loginIsManual;

    _loginIsManual = false;
    sendData(loginReqMsg.encode());
    _changeState(ClientState.loging);
  }

  //socket被关闭 清理socket连接
  void onSocketClose() {
    _dataBuf.reset(); //buf清空

    _socket?.destroy();
    _changeState(ClientState.unconnect);
    _socket = null;

    _heartBeat.stopHeartBeat();
    _reconnect.tiggerReconnect();
  }

  //接收到远端数据
  void _receiveRemoteData(Uint8List data) {
    ByteBuf recvBuf = ByteBuf.allocator(size: data.length);
    recvBuf.writeUint8List(data);
    LogUtil.log("received data  len : ${data.length}");

    _heartBeat.recordTime();

    _dataBuf.writeByteBuf(recvBuf);
    _dataBuf.debugHexPrint();

    while (_dataBuf.hasReadContent) {
      final DataStatus checkResult = _checkDataStatus(
          _dataBuf.copyWithSize(Message.headerSize()),
          _dataBuf.couldReadableSize); //使用备份来做检测 节省资源 仅取前32个协议头字节
      LogUtil.log("checkResult $checkResult");

      if (checkResult == DataStatus.success) {
        final Message? msg = parseByteBufToMessage(_dataBuf);
        _dataBuf.compact();

        //execute hand
        _handleMsg(msg);
      } else if (checkResult == DataStatus.errorLength) {
        break;
      } else {
        _socket?.destroy();
        break;
      }
    } //end while
  }

  //将原始数据解码成message
  Message? parseByteBufToMessage(ByteBuf buf) {
    Message msgHead = Message.fromBytebuf(buf);
    Message? result;
    switch (msgHead.type) {
      case MessageTypes.LOGIN_RESP: //登录消息响应
        result = IMLoginRespMessage.from(msgHead, buf);
        break;
      case MessageTypes.LOGOUT_RESP: //退出登录 消息响应
        result = LogoutRespMessage.from(msgHead, buf);
        break;
      case MessageTypes.SEND_IMMESSAGE_RESP: //发送消息获取响应
        result = SendIMMessageRespMsg.from(msgHead, buf);
        break;
      case MessageTypes.PUSH_IMMESSAGE_REQ: //发送过来的IMMessage
        result = PushIMMessageReqMsg.from(msgHead, buf);
        break;
      case MessageTypes.PONG: //心跳响应
        result = PongMessage();
        break;
      case MessageTypes.KICK_OFF: //被踢掉
        result = KickoffMessage();
        break;
      default:
        break;
    } //end switch
    return result;
  }

  //针对不同message 做不同业务处理
  void _handleMsg(Message? msg) {
    _receivedPacketCount++;

    MessageHandler? handler;

    LogUtil.log("messageType:${msg?.type}");
    switch (msg?.type) {
      case MessageTypes.LOGIN_RESP:
        handler = IMLoginRespHandler();
        break;
      case MessageTypes.LOGOUT_RESP:
        handler = LogoutRespHandler();
        break;
      case MessageTypes.SEND_IMMESSAGE_RESP:
        handler = SendIMMessageHandler();
        break;
      case MessageTypes.PUSH_IMMESSAGE_REQ: //发送过来的IMMessage
        handler = PushIMMessageHandler();
        break;
      case MessageTypes.PONG: //心跳响应处理
        break;
      case MessageTypes.KICK_OFF: //被踢掉
        handler = KickOffHandler();
        break;
      default:
        break;
    } //end switch

    handler?.handle(this, msg);

    //LogUtil.log("packetCount : $_receivedPacketCount");
  }

  //检测数据状态
  DataStatus _checkDataStatus(ByteBuf buf, int bufRealSize) {
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
    int lastLength = length; //剩余长度
    if (bufRealSize < lastLength) {
      return DataStatus.errorLength;
    }

    buf.readInt32();
    int encodeType = buf.readInt32();
    if (encodeType != ProtocolConfig.BodyEncodeType) {
      return DataStatus.errorBodyEncode;
    }

    return DataStatus.success;
  }

  //登录成功
  void loginSuccess() {
    LogUtil.log("login success");
    _changeState(ClientState.logined);

    _reconnect.stopReconnect(); //停止重连尝试
    _heartBeat.startHeartBeat();
    _reconnect.CouldReconnect = true; //标识 未来可以自动重连

    //init session
    if (_sessionManager != null) {
      if (_sessionManager?.uid != _uid) {
        _sessionManager?.dispose();
        _sessionManager = SessionManager(uid);
      }
    } else {
      //init session manager
      _sessionManager = SessionManager(uid);
    }
  }

  //自动重连
  void autoReconnect() {
    imLogin(_uid, _token!, manual: false);
  }

  void loginFailed() {
    LogUtil.log("login failed");
    _changeState(ClientState.unlogin);
  }

  //退出登录
  void afterLogout(bool logoutSuccess) {
    if (logoutSuccess) {
      LogUtil.log("login out");
      _changeState(ClientState.unlogin); //状态改为未登录
      _socket?.destroy(); //主动关闭socket

      _reconnect.CouldReconnect = false; //手动退出登录  不再进行重连
      onSocketClose();
    } else {
      _changeState(ClientState.logined);
    }
  }

  //通过socket 发送数据
  void sendData(ByteBuf buf) {
    LogUtil.log("send data size = ${buf.couldReadableSize}");
    buf.debugHexPrint();

    if (buf.couldReadableSize <= 0) {
      return;
    }

    // buf.debugPrint();
    try {
      _socket?.add(buf.readAllUint8List());
    } catch (e) {
      LogUtil.log("socket write error");
      onSocketClose();
    }
    _socket?.flush().catchError((error) {
      LogUtil.log("socket write error");
      onSocketClose();
    });
  }
} //end class
