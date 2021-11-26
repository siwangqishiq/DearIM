import 'package:dearim/pages/login_page.dart';
import 'package:dearim/pages/main_page.dart';
import 'package:dearim/routers/routers.dart';
import 'package:dearim/user/user_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
    Routers().addRouter("/login", (context) => const LoginPage());
    Routers().addRouter("/main", (context) => const MainPage());
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
    if (UserManager.getInstance()!.hasUser()) {
      return const MainPage();
    }
    return const LoginPage();
  }
}
