
// ignore_for_file: non_constant_identifier_names, constant_identifier_names

import 'dart:convert';

///
/// 自定义透传消息
///
class CustomTransTypes{
  static const String KEY_TYPE = "type";
  static const String KEY_CONTENT = "content";

  static const int TYPE_INPUTTING = 10; //正在输入中
}

class CustomTransBuilder{
  static String build(int type , String? content){
    Map<String , dynamic> json = {};
    json[CustomTransTypes.KEY_TYPE] = type;

    if(content != null){
      json[CustomTransTypes.KEY_CONTENT] = content;
    }
    return jsonEncode(json);
  }
}