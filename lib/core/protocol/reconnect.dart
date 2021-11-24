import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';

///
///client断线重连机制
///

class Reconnect{
  late IMClient _client;

  Reconnect(this._client);

  void tiggerReconnect(){
    LogUtil.log("tigger reconnect.");
  }
}//end class