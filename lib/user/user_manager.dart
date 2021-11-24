import 'package:dearim/network/request.dart';
import 'package:dearim/tcp/tcp_manager.dart';
import 'package:dearim/user/user.dart';
import 'package:logger/logger.dart';

class UserManager {
  static UserManager? _instance;
  User? user;

  static UserManager? getInstance() {
    // ignore: prefer_conditional_assignment
    if (_instance == null) {
      _instance = UserManager();
      _instance!.user = User();
    }
    return _instance;
  }

  bool hasUser() {
    if (user!.uid != 0) {
      return true;
    }
    return false;
  }

  void login(String name, String password, Callback? callback) {
    Map<String, Object> map = {};
    // http://192.168.31.230:9090/login?username=wenmingyan&pwd=111111
    map["username"] = name;
    map["pwd"] = password;
    Request().postRequest(
        "login",
        map,
        Callback(successCallback: (data) {
          Logger().d("success = ($data)");
          // 配置登录参数
          user!.token = data["token"];
          user!.uid = data["uid"];
          user!.tcpParam.imPort = data["imPort"];
          user!.tcpParam.imServer = data["imServer"];
          if (callback != null && callback.successCallback != null) {
            callback.successCallback!(data);
            // 连接TCP
            TCPManager().connect(user!.uid, user!.token);
          }
        }, failureCallback: (code, errorStr, data) {
          Logger().d("login failure : ($errorStr)");
          if (callback != null && callback.failureCallback != null) {
            callback.failureCallback!(code, errorStr, data);
          }
        }));
  }

  void logout(Callback? callback) {
    user!.clear();
    if (callback != null && callback.successCallback != null) {
      callback.successCallback!(null);
      // 断连TCP
      TCPManager().disconnect();
    }
  }
}