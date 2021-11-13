import 'dart:io';

class LogUtil {
  static void log(String? msg) {
    print(msg);
  }
  
  static void errorLog(String? errMsg){
    stderr.write("$errMsg\n");
  }
}
