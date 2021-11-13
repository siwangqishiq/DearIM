import 'package:dearim/user/User.dart';

class UserManager {
  UserManager._privateConstructor();

  static final UserManager _instance = UserManager._privateConstructor();

  User? user;
  factory UserManager() {
    return _instance;
  }

  bool hasUser() {
    if (this.user != null && this.user!.uid != 0) {
      return true;
    }
    return false;
  }
}
