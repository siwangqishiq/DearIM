import 'package:dearim/core/imcore.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/pages/contact_page.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/views/contact_view.dart';
import 'package:dearim/views/head_view.dart';
import 'package:flutter/material.dart';


class ProfilePage extends StatelessWidget {
  const ProfilePage({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          MyInfoWidget(),
        ],
      ),
    );
  }
}

///
/// 个人信息栏
///
class MyInfoWidget extends StatefulWidget{
  // ignore: prefer_const_constructors_in_immutables
  MyInfoWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return MyInfoState();
  }
}

class MyInfoState extends State<MyInfoWidget>{
  String? name;
  String? avatar;
  String? account ="";
  int uid = 0;

  ContactModel _info = ContactModel("", 0);

  late VoidCallback _infoChangeCallback;

  @override
  void initState() {
    super.initState();
    _infoChangeCallback = (){
      _displayMyInfo();
    };
    ContactsDataCache.instance.addListener(_infoChangeCallback);

    _displayMyInfo();
  }

  void _displayMyInfo(){
    uid = IMClient.getInstance().uid;
    
    ContactModel? info = ContactsDataCache.instance.getContact(uid);
    name = info?.name;
    avatar = info?.avatar;
    account = info?.account;

    _info = info??ContactModel("", 0);
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 40,),
          HeadView(
            avatar , 
            size: ImageSize.middle,
            width: 150,
            height: 150,
            circle: 100,
          ),
          const SizedBox(height: 8,),
          Text(name??"" , style:const TextStyle(fontSize: 20 , color: Colors.black),),
          const SizedBox(height: 4,),
          Text(uid.toString(),style:const TextStyle(fontSize: 16 , color: Colors.black))
        ],
      ),
    );
  }

  @override
  void dispose() {
    ContactsDataCache.instance.removeListener(_infoChangeCallback);
    super.dispose();
  }
}
