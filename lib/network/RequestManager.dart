import 'package:flutter/foundation.dart';

enum NetworkEnvironment {
  Online,
  Daily,
}

class RequestManager {
  NetworkEnvironment networkEnv = NetworkEnvironment.Online;
  String _hostName = "";
  RequestManager._privateConstructor();

  static final RequestManager _instance = RequestManager._privateConstructor();

  factory RequestManager() {
    if (kDebugMode) {
      _instance.networkEnv = NetworkEnvironment.Daily;
      _instance._hostName = "http://192.168.31.230:9090/";
    }
    return _instance;
  }

  String hostName() {
    if (this.networkEnv == NetworkEnvironment.Online) {
      return "http://47.99.103.133:9090/";
    }
    return _hostName;
  }
}