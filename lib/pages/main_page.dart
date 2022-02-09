import 'package:dearim/config.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:flutter/material.dart';

import 'session_list_page.dart';
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
    controller.addListener((){
      // LogUtil.log("cur ${controller.index}");
      setState(() {
      });
    });
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
    const double tabSize = 26;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          APP_NAME,
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: TabBarView(
        controller: controller, 
        children:const [
          SessionPage(),
          ContactPage(),
          ProfilePage(),
        ]
      ),
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index){
          setState(() {
            controller.index = index;
          });
        },
        iconSize: tabSize,
        currentIndex: controller.index,
        items:const [
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: "聊天",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.contact_mail),
            label: "通讯录",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "我的",
          ),
        ],
      ),

      // bottomNavigationBar: Material(
      //   color: Colors.white,
      //   child: TabBar(
      //     controller: controller,
      //     labelColor: ColorThemes.themeColor,
      //     unselectedLabelColor: ColorThemes.unselectColor,
      //     indicator: const BoxDecoration(),
      //     tabs: const [
      //       Tab(
      //         text: "聊天",
      //         icon: Icon(Icons.chat),
      //         height: tabSize,
      //         iconMargin: tabMargin,
      //       ),
      //       Tab(
      //         text: "通讯录",
      //         icon: Icon(Icons.contact_mail),
      //         height: tabSize,
      //         iconMargin: tabMargin
      //       ),
      //       Tab(
      //         text: "我的",
      //         icon: Icon(Icons.person_outline),
      //         height: tabSize,
      //         iconMargin: tabMargin
      //       ),
      //     ]
      //   ),
      // ),
    );
  }
}
