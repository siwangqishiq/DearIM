import 'package:dearim/pages/LoginPage.dart';
import 'package:dearim/routers/routers.dart';
import 'package:dearim/user/UserManager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'Pages/ChatPage.dart';
import 'Pages/MainPage.dart';
import 'core/core_test.dart';

void main() {
  runApp(const MyApp());
  // coreTestRun();
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Routers().addRouter("/login", (context) => LoginPage());
    Routers().addRouter("/main", (context) => MainPage());
    // Routers().addRouter("/chat", (context, {model}) => ChatPage(model: model));
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
