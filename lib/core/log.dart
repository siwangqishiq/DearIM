import 'dart:io';

class LogUtil {
  static const bool debug = true;


  static void log(String? msg) {
    if(!debug){
      return;
    }
    
    print(msg);
  }
  
  static void errorLog(String? errMsg){
    stderr.write("$errMsg\n");
  }
}
