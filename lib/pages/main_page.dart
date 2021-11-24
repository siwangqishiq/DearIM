import 'package:dearim/network/request.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/views/toast_show_utils.dart';

import 'package:flutter/material.dart';

import 'chat_list_page.dart';
import 'contact_page.dart';
import 'profile_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage>
    with SingleTickerProviderStateMixin {
  late TabController controller;
  @override
  void initState() {
    super.initState();
    controller = new TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          MaterialButton(
            child: const Icon(
              Icons.logout,
              color: Colors.white,
            ),
            onPressed: () {
              ToastShowUtils.showAlert("确定登出吗", "", context, () {
                UserManager.getInstance()!
                    .logout(Callback(successCallback: (data) {
                  Navigator.of(context).pop();
                  Navigator.of(context).pushNamed("/login");
                }));
              }, () {});
            },
          )
        ],
        title: const Text(
          "展信佳",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: TabBarView(controller: controller, children: [
        const ChatListPage(),
        ContactPage(),
        ProfilePage(),
      ]),
      bottomNavigationBar: new Material(
        color: Colors.white,
        child: TabBar(
            controller: controller,
            labelColor: Colors.deepPurpleAccent,
            unselectedLabelColor: Colors.black26,
            tabs: [
              Tab(
                text: "聊天",
                icon: Icon(Icons.chat),
              ),
              Tab(
                text: "通讯录",
                icon: Icon(Icons.contact_mail),
              ),
              Tab(
                text: "我的",
                icon: Icon(Icons.portable_wifi_off_outlined),
              ),
            ]),
      ),
    );
  }
}