import 'package:dearim/network/Request.dart';
import 'package:dearim/tcp/TCPManager.dart';
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
          // 配置登录参数
          this.user.token = data["token"];
          this.user.uid = data["uid"];
          this.user.tcpParam.imPort = data["imPort"];
          this.user.tcpParam.imServer = data["imServer"];
          if (callback != null && callback.successCallback != null) {
            callback.successCallback!(data);
            // 连接TCP
            TCPManager().connect(this.user.uid, this.user.token);
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
      // 断连TCP
      TCPManager().disconnect();
    }
  }
}
