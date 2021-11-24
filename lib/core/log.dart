import 'dart:io';

class LogUtil {
  /// 是否为Release模式
  static const bool isReleaseMode = bool.fromEnvironment("dart.vm.product");

  static void log(String? msg) {
    if(isReleaseMode){
      return;
    }
    
    // ignore: avoid_print
    print(msg);
  }
  
  static void errorLog(String? errMsg){
    stderr.write("$errMsg\n");
  }
}
