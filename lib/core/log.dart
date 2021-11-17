import 'dart:io';

class LogUtil {
  final static bool debug = true;


  static void log(String? msg) {
    print(msg);
  }
  
  static void errorLog(String? errMsg){
    stderr.write("$errMsg\n");
  }
}
