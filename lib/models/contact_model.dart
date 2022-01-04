import 'package:dearim/user/user.dart';

class ContactModel {
  String name = "";
  int userId = 0;
  String message = "";
  String avatar = "";
  String account = "";
  int updatetime = 0;
  
  User user = User();
  ContactModel(this.name, this.userId);
}
