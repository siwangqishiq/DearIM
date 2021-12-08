import 'package:dearim/pages/login_page.dart';
import 'package:dearim/pages/main_page.dart';
import 'package:dearim/routers/routers.dart';
import 'package:dearim/user/user.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'core/core_test.dart';
import 'tcp/tcp_manager.dart';

void main() {
  runApp(const MyApp());
  // coreTestRun();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Routers().addRouter("/login", (context) => const LoginPage());
    Routers().addRouter("/main", (context) => const MainPage());
    // Routers().addRouter("/chat", (context, {model}) => ChatPage(model: model));
    return MaterialApp(
      title: 'dearIM',
      debugShowCheckedModeBanner: isNeedShowDebug(),
      theme: ThemeData(primarySwatch: ColorThemes.themeColor),
      home: FutureBuilder(
        future: getUser(),
        builder: (BuildContext context, AsyncSnapshot<User> snapshot) {
          if (snapshot.data == null) {
            //todo 显示一个欢迎页
            return Scaffold(
              body: Container(
                color: ColorThemes.themeColor,
                child: const Center(
                  child: Text(
                    "Welcome",
                    style: TextStyle(fontSize: 30.0, color: Colors.white),
                  ),
                ),
              ),
            );
          }
          return nextPage(snapshot.data!);
        },
      ),
      routes: Routers().routers,
    );
  }

  bool isNeedShowDebug() {
    if (kDebugMode) {
      return true;
    }
    return false;
  }

  Future<User> getUser() async {
    User user = User();
    await user.restore();
    UserManager.getInstance()?.user = user;

    return user;
  }

  Widget nextPage(User user) {
    //print("是否可以自动登录: ${user.canAutoLogined()}");
    if (user.canAutoLogined()) {
      // 连接TCP
      TCPManager().connect(user.uid, user.token);
      return const MainPage();
    }
    return const LoginPage();
  }
}
