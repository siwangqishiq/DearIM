import 'package:dearim/pages/LoginPage.dart';
import 'package:dearim/routers/routers.dart';
import 'package:dearim/user/UserManager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'Pages/MainPage.dart';
import 'core/imcore.dart';

void main() {
  initIM();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Routers().addRouter("/login", (context) => LoginPage());
    Routers().addRouter("/main", (context) => MainPage());
    return MaterialApp(
      title: 'dearIM',
      debugShowCheckedModeBanner: isNeedShowDebug(),
      theme: ThemeData(primarySwatch: Colors.lightGreen),
      home: homepage(),
      routes: Routers().routers,
    );
  }

  bool isNeedShowDebug() {
    if (kDebugMode) {
      return true;
    }
    return false;
  }

  Widget homepage() {
    if (UserManager().hasUser()) {
      return MainPage();
    }
    return LoginPage();
  }
}


//im client test
void initIM() {
  int uid = 1;
  String token =
      "eyJ0eXAiOiJKV1QiLCJfdWlkIjoiMSIsImFsZyI6IkhTMjU2In0.eyJleHAiOjE2MzcwMjI3NTl9.B2yT4X5gQVo80RExbZZd2QZECwtC5a073Rv2wQhglFM";
  IMClient.instance.imLogin(uid, token);
}
