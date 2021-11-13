import 'package:dearim/network/Request.dart';
import 'package:dearim/user/User.dart';
import 'package:logger/logger.dart';

class UserManager {
  UserManager._privateConstructor();

  static final UserManager _instance = UserManager._privateConstructor();

  User user = User();
  factory UserManager() {
    return _instance;
  }

  bool hasUser() {
    if (this.user.uid != 0) {
      return true;
    }
    return false;
  }

  void login(String name, String password, Callback? callback) {
    Map<String, Object> map = Map();
    // http://192.168.31.230:9090/login?username=wenmingyan&pwd=111111
    map["username"] = name;
    map["pwd"] = password;
    Request().postRequest(
        "login",
        map,
        Callback(successCallback: (data) {
          Logger().d("success = ($data)");
          this.user.token = data["token"];
          this.user.uid = data["uid"];
          if (callback != null && callback.successCallback != null) {
            callback.successCallback!(data);
          }
        }, failureCallback: (code, errorStr, data) {
          Logger().d("login failure : ($errorStr)");
          if (callback != null && callback.failureCallback != null) {
            callback.failureCallback!(code, errorStr, data);
          }
        }));
  }

  void logout(Callback? callback) {
    this.user.clear();
    if (callback != null && callback.successCallback != null) {
      callback.successCallback!(null);
    }
  }
}
