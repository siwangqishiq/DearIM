import 'package:dearim/network/RequestManager.dart';
import 'package:dearim/user/UserManager.dart';
import 'package:logger/logger.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:dio/dio.dart';

typedef SuccessCallback = void Function(dynamic data);
typedef FailureCallback = void Function(
    int code, String errorStr, dynamic data);

class Callback {
  SuccessCallback? successCallback;
  FailureCallback? failureCallback;
  Callback({this.successCallback, this.failureCallback});
}

class Request {
  String host = RequestManager().hostName();

  static final Request _instance = Request._privateConstructor();
  Request._privateConstructor();

  factory Request() {
    return _instance;
  }

  void uploadRequest(String apiName, String filePath, Map<String, dynamic> map,
      Callback callback) async {
    Response response;
    Map<String, dynamic> param = new Map<String, dynamic>();
    param.addAll(map);
    param["file"] = await MultipartFile.fromFile(filePath, filename: filePath);
    FormData formData = new FormData.fromMap(
        {"file": await MultipartFile.fromFile(filePath, filename: filePath)});
    try {
      response = await Dio().post(apiName, data: formData);
      Map<String, dynamic> responseMap = response.data;
      Logger().d(responseMap);
      int code = responseMap["code"];
      if (code != 200) {
        // 返回失败内容 给出回调
        if (callback.failureCallback != null) {
          callback.failureCallback!(
              responseMap["code"], responseMap["msg"], responseMap["data"]);
        }
        //TODO: wmy code 的处理
      } else {
        if (callback.successCallback != null) {
          dynamic data = responseMap["data"];
          callback.successCallback!(data);
          Logger().d(data);
        }
      }
    } catch (e) {
      // Logger().d("catch e" + e.toString());
      // if (callback.failureCallback != null) {
      //   if (e.response != null) {
      //     callback.failureCallback!(e.response.data["code"],
      //         e.response.data["message"], e.response.data["data"]);
      //   }
      // }
    }
  }

  void postRequest(
      String apiName, Map<String, dynamic> map, Callback callback) async {
    Response response;
    Map<String, dynamic> param = new Map<String, dynamic>();
    param.addAll(map);
    String? token = UserManager().user.token;

    if (token.length != 0) {
      print(UserManager().user.token);
      param["token"] = UserManager().user.token;
    }
    try {
      FormData formData = FormData.fromMap(param);
      String address = host + apiName;
      Logger().d("address = " + address);
      Logger().i(map);
      response = await Dio().post(address, data: formData);

      Map<String, dynamic> responseMap = response.data;
      Logger().d(responseMap);
      int code = responseMap["code"];
      if (code != 200) {
        // 返回失败内容 给出回调
        if (callback.failureCallback != null) {
          callback.failureCallback!(
              responseMap["code"], responseMap["message"], responseMap["data"]);
        }
      } else {
        if (callback.successCallback != null) {
          dynamic data = responseMap["data"];
          callback.successCallback!(data);
          print(data);
        }
      }
    } catch (e) {
      // Logger().d("catch e" + e);
      // if (callback.failureCallback != null) {
      //   if (e.response != null) {
      //     callback.failureCallback(e.response.data["code"],
      //         e.response.data["message"], e.response.data["data"]);
      //   }
      // }
    }
    return null;
  }
}
