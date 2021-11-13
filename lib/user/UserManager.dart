import 'package:dearim/user/User.dart';

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

  void login(String token, int uid) {
    this.user.token = token;
    this.user.uid = uid;
  }

  void logout() {
    this.user.clear();
  }
}
