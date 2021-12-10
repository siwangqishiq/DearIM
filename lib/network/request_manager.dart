import 'package:flutter/foundation.dart';

enum NetworkEnvironment {
  online,
  daily,
}

class RequestManager {
  //TODO: 线上环境变化
  NetworkEnvironment networkenv = NetworkEnvironment.daily;
  String _hostName = "";
  RequestManager._privateConstructor();

  static final RequestManager _instance = RequestManager._privateConstructor();

  factory RequestManager() {
    if (kDebugMode) {
      // _instance.networkenv = NetworkEnvironment.daily;
      _instance._hostName = "http://192.168.31.230:9090/"; // mac
      // _instance._hostName = "http://192.168.31.37:9090/"; // windows
      // _instance._hostName = "http://10.242.142.129:9090/";
      // _instance._hostName = "http://fuckalibaba.xyz:9090/";
    }
    return _instance;
  }

  String hostName() {
    if (networkenv == NetworkEnvironment.online) {
      return "http://47.99.103.133:9090/";
    }
    return _hostName;
  }
}
