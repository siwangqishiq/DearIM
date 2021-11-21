import 'dart:developer';
import 'dart:io';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/utils.dart';

class TCPManager {
  TCPManager._privateConstructor();

  static final TCPManager _instance = TCPManager._privateConstructor();

  factory TCPManager() {
    IMClient.getInstance()!.registerStateObserver((oldState, newState) {
      log("change state $oldState to $newState");
    }, true);
    return _instance;
  }

  // 注册状态变化回调
  void registerStateChangeback(StateChangeCallback callback) {
    IMClient.getInstance()?.registerStateObserver(callback, true);
  }

  // 删除注册
  void unregisterStateChangeback(StateChangeCallback callback) {
    IMClient.getInstance()?.registerStateObserver(callback, false);
  }

  // 注册消息回调
  void registerMessageCommingCallbck(IMMessageIncomingCallback callback) {
    IMClient.getInstance()?.registerIMMessageIncomingObserver(callback, true);
  }

  // 删除注册消息回调
  void unregistMessageCommingCallback(IMMessageIncomingCallback callback) {
    IMClient.getInstance()?.registerIMMessageIncomingObserver(callback, false);
  }

  // 连接tcp
  void connect(int uid, String token) {
    IMClient.getInstance()?.imLogin(uid, token, loginCallback: (result) {
      if (result.result) {
        log("IM登录成功");
      } else {
        log("IM登录失败 原因: ${result.reason}");
      }
    });
  }

  // 取消连接tcp
  void disconnect() {
    IMClient.getInstance()?.imLoginOut(loginOutCallback: (r) {
      log("退出登录: ${r.result}");
    });
  }

  void sendMessage(String content, int toUid) {
    IMMessage? msg =
        IMMessageBuilder.createText(toUid, IMMessageSessionType.P2P, content);
    if (msg != null) {
      IMClient.getInstance()?.sendIMMessage(msg, callback: (imMessage, result) {
        log("send im message ${result.code}");
      });
    }
  }
}
