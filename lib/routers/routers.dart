import 'package:flutter/material.dart';

class Routers {
  static final Routers _instance = Routers._privateConstructor();
  Routers._privateConstructor();

  factory Routers() {
    return _instance;
  }

  var routers = new Map<String, WidgetBuilder>();
  void addRouter(String router, WidgetBuilder operation) {
    if (router.length > 0) {
      routers[router] = operation;
    }
  }
}
