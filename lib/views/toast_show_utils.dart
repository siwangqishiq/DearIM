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

  static void showAlert(String title, String content, BuildContext context,
      VoidCallback? sureCallback, VoidCallback? cancelCallback) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return new AlertDialog(
          title: new Text(
            title,
          ),
          content: new Text(content),
          actions: <Widget>[
            new Container(
              decoration: BoxDecoration(
                  border: Border(
                      right: BorderSide(color: Colors.white, width: 1.0),
                      top: BorderSide(color: Colors.white, width: 1.0))),
              child: FlatButton(
                child: new Text("确定"),
                onPressed: () {
                  Navigator.pop(context);
                  if (sureCallback != null) {
                    sureCallback();
                  }
                },
              ),
            ),
            new Container(
              decoration: BoxDecoration(
                  border:
                      Border(top: BorderSide(color: Colors.white, width: 1.0))),
              child: FlatButton(
                child: new Text("取消"),
                onPressed: () {
                  Navigator.pop(context);
                  if (cancelCallback != null) {
                    cancelCallback();
                  }
                },
              ),
            )
          ],
        );
      },
    );
  }
}
