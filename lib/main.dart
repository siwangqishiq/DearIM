import 'package:dearim/pages/LoginPage.dart';
import 'package:dearim/user/UserManager.dart';
import 'package:flutter/material.dart';

import 'Pages/MainPage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'dearIM',
        theme: ThemeData(primarySwatch: Colors.lightGreen),
        home: homepage());
  }

  Widget homepage() {
    if (UserManager().hasUser()) {
      return MainPage();
    }
    return LoginPage();
  }
}
