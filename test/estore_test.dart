import 'dart:io';

import 'package:dearim/core/estore/estore.dart';
import 'package:dearim/core/log.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("test file create", () {
    File file = File("panyi.txt");
    if (!file.existsSync()) {
      file.createSync();
    }

    file.writeAsString("Hello Werld你好 世界");

    LogUtil.log("path: ${file.absolute.path}");

    file.deleteSync();
  });

  test("open estore db", () {
    EasyStore store = EasyStore.fromFile("store.db");
  });
}
