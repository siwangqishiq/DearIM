import 'dart:io';

import 'package:dearim/core/byte_buffer.dart';
import 'package:dearim/core/log.dart';
import 'package:path_provider/path_provider.dart';

import 'estore_table.dart';

///
/// easy store
///
///

abstract class Codec<T> {
  ByteBuf encode();

  T decode(ByteBuf buf);

  String key();
}

class User with Codec<User> {
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
  String key() {
    return "user";
  }
}

class EasyStore {
  static const List<int> MagicNumbers = [7, 7, 8, 8];

  String _dbName = "";

  late Directory workDir;
  late File dbFile;

  int _version = 1; //版本

  final ByteBuf _dataBuf = ByteBuf.allocator();

  bool isInit = false;

  Map<String, StoreTable> tables = <String, StoreTable>{};

  factory EasyStore.open(String dbName) {
    final EasyStore result = EasyStore();
    result._dbName = dbName;

    result.findLocalPath().then((value) {
      print("数据库路径:${value}");
      result._init(value);
    });
    return result;
  }

  EasyStore();

  void _init(String _workDir) {
    workDir = Directory(_workDir);
    dbFile = File("${workDir.path}/$_dbName");

    LogUtil.log("db文件路径 :${dbFile.absolute.path}");

    if (!dbFile.existsSync()) {
      _createDbFile();
    }

    workDir = dbFile.parent;
    LogUtil.log("工作目录: ${workDir.absolute.path}");

    _readDataBaseConfig();

    isInit = true;
  }

  //创建db文件
  void _createDbFile() {
    dbFile.createSync(recursive: true);
    reSaveDb();
    LogUtil.log("创建db文件 ${dbFile.absolute.path}");
  }

  Future<String> findLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.absolute.path;
  }

  void reSaveDb() {
    ByteBuf buf = ByteBuf.allocator(size: 32);
    //write magic number
    buf.writeInt8(MagicNumbers[0]);
    buf.writeInt8(MagicNumbers[1]);
    buf.writeInt8(MagicNumbers[2]);
    buf.writeInt8(MagicNumbers[3]);

    //write version
    buf.writeInt16(_version);

    //write table config
    buf.writeInt32(tables.length);
    for (String key in tables.keys) {
      StoreTable table = tables[key]!;
      buf.writeString(table.name);
      buf.writeString(table.path);
    } //end for each

    dbFile.writeAsBytesSync(buf.readAllUint8List());
  }

  //写入配置
  int _readDataBaseConfig() {
    ByteBuf buf = ByteBuf.allocator(size: dbFile.lengthSync());
    var content = dbFile.readAsBytesSync();
    buf.writeUint8List(content);

    for (var v in MagicNumbers) {
      if (v != buf.readInt8()) {
        LogUtil.log("db magic number error!");
        return -1;
      }
    } //end for each

    _version = buf.readInt16();
    LogUtil.log("db current version $_version");

    int tableCount = buf.readInt32();
    LogUtil.log("db tableCount $tableCount");

    for (int i = 0; i < tableCount; i++) {
      String name = buf.readString() ?? "";
      String path = buf.readString() ?? "";

      tables[name] = StoreTable(name, path);
    } //end for i
    return 0;
  }

  int save(Codec data) {
    return 0;
  }

  int remove(Codec data) {
    return 0;
  }

  int update(Codec data) {
    return 0;
  }

  List<Codec> query(Codec data) {
    return <Codec>[];
  }
}
