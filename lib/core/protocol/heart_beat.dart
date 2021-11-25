import 'dart:async';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import '../utils.dart';
import 'message.dart';
import 'protocol.dart';


class PingMessage extends Message{
  @override
  int getType() {
    return MessageTypes.PING;
  }
}

class PongMessage extends Message{
  @override
  int getType() {
    return MessageTypes.PONG;
  }
}

///
/// 长链接心跳
///
class HeartBeat{
  late IMClient _client;

  final Duration _deltaTime = const Duration(minutes: 2);//代表最大等待时间

  Timer? _timer;

  int _lastIoTime = -1;//记录上一次io操作时间

  HeartBeat(this._client);

  //开始心跳
  void startHeartBeat(){
    LogUtil.log("start heart beat");
    _timer?.cancel();
    _timer = null;

    //启动定时器
    _timer = Timer.periodic(_deltaTime, (timer) {
      final int curTime = Utils.currentTime();
      // if(curTime - _lastIoTime > 4 * _deltaTime.inMilliseconds){//超出了心跳包时间的4倍 判定为连接断开
      //   _judgeSocketDead();
      //   return;
      // }

      if(curTime - _lastIoTime > (_deltaTime.inMilliseconds >> 1)){//超过最大等待时间的一半 发送心跳包
        _sendPingPkg(timer);
      }else{
        LogUtil.log("net is working skip this heart beat tick! delta : ${curTime - _lastIoTime}");
      }
    });
  }

  void _judgeSocketDead(){
    LogUtil.log("heart beat judge socket has die!");
    _client.onSocketClose();
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
    LogUtil.log("send heart beat ping...");
    final PingMessage pingMsg = PingMessage();
    _client.sendData(pingMsg.encode());
  }
}//end class



