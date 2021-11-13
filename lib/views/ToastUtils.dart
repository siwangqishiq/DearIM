import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastShowUtils {
  static void show(String _msg, BuildContext context) {
    if (kIsWeb || Platform.isWindows || Platform.isMacOS) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_msg)));
    } else {
      Fluttertoast.showToast(msg: _msg);
    }
  }
}
