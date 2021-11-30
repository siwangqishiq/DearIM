import 'dart:developer';

import 'package:dearim/pages/chat_page.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/network/request.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/views/contact_view.dart';
import 'package:flutter/material.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({Key? key}) : super(key: key);

  @override
  ContactPageState createState() => ContactPageState();
}

class ContactPageState extends State<ContactPage> {
  List<ContactModel> models = <ContactModel>[];
  @override
  void initState() {
    super.initState();
    //requestChatList();
    
    models.clear();
    models.addAll(ContactsDataCache.instance.allContacts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text("通讯录"),
      // ),
      body: ListView.builder(
        itemCount: models.length,
        itemBuilder: (BuildContext context, int index) {
          ContactModel contactModel = models[index];
          return Column(
            children: [
              ContactView(contactModel, () {
                //跳转传参
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (BuildContext context, Animation<double> animation,
                        Animation<double> secondaryAnimation) {
                      return ChatPage(contactModel);
                    },
                  ),
                );
              }),
              const Divider(height: 1,color: Colors.grey,)
            ],
          );
        },
      ),
    );
  }

  // requestChatList() {
  //   Request().postRequest(
  //     "/contacts",
  //     {},
  //     Callback(successCallback: (data) {
  //       models.clear();
  //       List list = data["list"];
  //       for (Map item in list) {
  //         ContactModel model = ContactModel(item["name"], item["uid"]);
  //         model.avatar = item["avatar"] ?? "";

  //         model.user.uid = item["uid"];
  //         model.user.name = item["name"];
  //         model.user.avatar = item["avatar"] ?? "";
  //         model.user.account = item["account"]??"";
          
  //         if (item["uid"] == UserManager.getInstance()!.user!.uid) {
  //           UserManager.getInstance()!.user!.avatar = item["avatar"] ?? "";
  //         }
  //         models.add(model);
  //       }

  //       ContactsDataCache.instance.resetContacts(models);
  //       setState(() {});
  //     }, failureCallback: (code, msgStr, data) {
  //       log(data);
  //     }),
  //   );
  // }
}
