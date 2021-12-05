
import 'dart:io';

import 'package:dearim/core/log.dart';
import 'package:flutter_test/flutter_test.dart';

void main(){
  
  test("test file create", (){
    File file = File("panyi.txt");
    if(!file.existsSync()){
      file.createSync();
    }
    
    file.writeAsString("Hello Werld你好 世界");
    
    LogUtil.log("path: ${file.absolute.path}");

    file.deleteSync();
  });

  test("test 1" , (){

  });
}

