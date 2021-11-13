import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';

void main() {
  Future<Socket> socketFuture = Socket.connect(
      IMClient.SERVER_ADDRESS, IMClient.PORT,
      timeout: const Duration(seconds: 10));
  socketFuture.then((socket) {
    LogUtil.log("连接成功! server ${socket.remoteAddress} : ${socket.remotePort}");

    socket.listen((Uint8List data) {
      LogUtil.log("received data  len : ${data.length}");

      ByteBuf buf = ByteBuf.allocator();
      buf.writeUint8List(data);
      buf.debugPrint();

      int value = buf.readInt();
      LogUtil.log("int value = $value ");

      int value2 = buf.readInt64();
      LogUtil.log("long value = $value2 ");

      final int strLen = buf.readInt();
      Uint8List strBytes = buf.readUint8List(strLen);
      String str = utf8.decode(strBytes);
      LogUtil.log("str : ${str}");

      buf.debugPrint();

      socket.close();
    });
  }).catchError((error) {
    print("Error 连接socket失败");
  });

  // var inputLine = stdin.readLineSync();
  // print("input: $inputLine");
}
