import 'package:dearim/config.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/views/color_utils.dart';
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
    controller = TabController(length: 3, vsync: this);
    _fetchContacts();
  }

  //获取通讯录数据
  void _fetchContacts() {
    ContactsDataCache.instance.fetchContacts();
  }

  @override
  void dispose() {
    IMClient.getInstance().dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          APP_NAME,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: TabBarView(controller: controller, children:const [
        SessionPage(),
        ContactPage(),
        ProfilePage(),
      ]),
      bottomNavigationBar: Material(
        color: Colors.white,
        child: TabBar(
            controller: controller,
            labelColor: ColorThemes.themeColor,
            unselectedLabelColor: ColorThemes.unselectColor,
            indicator: const BoxDecoration(),
            tabs: const [
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
