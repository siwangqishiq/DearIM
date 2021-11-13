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

void initIM() {
  int uid = 1001;
  String token =
      "eyJ0eXAiOiJKV1QiLCJfdWlkIjoiMTAwMSIsImFsZyI6IkhTMjU2In0.eyJleHAiOjE2MzY4MzY5Nzh9.SDvudzHirrbwWvNopPd1JS3eY6PYZYaidE8_1083cxk";
  IMClient.instance.imLogin(uid, token);
}
