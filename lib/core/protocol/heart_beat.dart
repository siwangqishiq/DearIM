import 'dart:async';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import 'package:flutter/cupertino.dart';

import '../utils.dart';

///
/// 长链接心跳
///
class HeartBeat{
  late IMClient _client;

  final Duration _deltaTime = const Duration(seconds: 5);//代表最大等待时间

  Timer? _timer;

  int _lastIoTime = -1;//记录上一次io操作时间

  HeartBeat(this._client);

  //开始心跳
  void startHeartBeat(){
    LogUtil.log("start heart beat");

    //启动定时器
    _timer = Timer.periodic(_deltaTime, (timer) {
      final int curTime = Utils.currentTime();
      if(curTime - _lastIoTime >= _deltaTime.inMilliseconds){//超过最大等待时间 发送心跳包
        _sendPingPkg(timer);
      }else{
        LogUtil.log("net is wokring skip this heart beat tick!");
      }
    });
  }

  //停止心跳
  void stopHeartBeat(){
    LogUtil.log("stop heart beat!");
    _timer?.cancel();
    _timer = null;
  }

  //记录操作当前时间 在有网络交互时
  void recordTime(){
    _lastIoTime = Utils.currentTime();
  }

  //发送客户端心跳包
  void _sendPingPkg(Timer timer){
    //todo
     LogUtil.log("timer run ${timer.tick}");
  }
}//end class



