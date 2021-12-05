import 'dart:html';

import 'package:dearim/core/byte_buffer.dart';

///
/// easy store
///
///

abstract class Codec<T>{
  int unique();

  ByteBuf encode();

  T decode(ByteBuf buf);
}

class User with Codec<User>{
  int id = 0;
  String? name;
  int age = -1;
  String? desc;

  @override
  User decode(ByteBuf buf) {
    return User();
  }

  @override
  ByteBuf encode() {
    return ByteBuf.allocator();
  }

  @override
  int unique() {
    return id;
  }
}

class EasyStore{
  factory EasyStore.fromFile(String path){
    return EasyStore(path);
  }

  late String _filepath;

  final ByteBuf _dataBuf = ByteBuf.allocator();

  EasyStore(this._filepath);

  int save(String key , Codec data){
    ByteBuf buf = data.encode();
    _dataBuf.writeByteBuf(buf);
    return 0;
  }

  int remove(String key , Codec data){
    return 0;
  }

  int update(String key , Codec data){

    return 0;
  }

  List<Codec> query(String key ,Codec data){
    return <Codec>[];
  }
}


