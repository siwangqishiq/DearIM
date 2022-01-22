///
///
///

import 'dart:io';

import 'package:dearim/core/immessage.dart';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../log.dart';

part 'im_table.g.dart';

///
///
/// int size = 0; //消息总大小
  // String msgId = ""; //消息唯一标识
  // int fromId = 0; //发送人ID
  // int toId = 0; //接收人ID
  // int createTime = 0;
  // int updateTime = 0;

  // int imMsgType = 0; //消息类型
  // int sessionType = IMMessageSessionType.P2P;
  // int msgState = 0; //消息状态
  // int readState = 1; //已读状态 0已读  1未读
  // int fromClient = 0;
  // int toClient = 0;

  // String? content; //消息内容
  // String? url; //资源Url
  // int attachState = 0; //附件状态
  // String? attachInfo; //附件信息
  // String? localPath; //资源本地路径
  // String? custom; //自定义扩展字段

  // bool isReceived = false; //是否是接收消息 此字段不参与传输
///

//消息表 sqlite存储
class IMMessageData extends Table{
  IntColumn get id => integer().autoIncrement()();
  IntColumn get size => integer()();
  TextColumn get msgId => text()();
  IntColumn get fromId => integer()();
  IntColumn get toId => integer()();
  IntColumn get createTime => integer()();
  IntColumn get updateTime => integer()();

  IntColumn get imMsgType => integer()();
  IntColumn get sessionType => integer()();
  IntColumn get msgState => integer()();
  IntColumn get readState => integer()();
  IntColumn get fromClient => integer()();
  IntColumn get toClient => integer()();

  TextColumn get content => text().nullable()();
  TextColumn get url => text().nullable()();
  IntColumn get attachState => integer()();
  TextColumn get attachInfo => text().nullable()();
  TextColumn get localPath => text().nullable()();
  TextColumn get custom => text().nullable()();
  
  IntColumn get isReceived => integer()();
} 

//打开数据库连接  按用户名分配
LazyDatabase openDataBaseConnection(int uid) {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();

    final file = File(p.join(dbFolder.path, "im$uid.db"));
    LogUtil.log("db路径: ${file.path}");
    return NativeDatabase(file);
  });
}

@DriftDatabase(tables:[IMMessageData])
class IMDatabase extends _$IMDatabase{
  final int _uid;

  int get uid => _uid;

  IMDatabase(this._uid) : super(openDataBaseConnection(_uid));

  @override
  int get schemaVersion => 1;

  Future<int> saveIMMessage(IMMessage imMsg) async{
    return await into(iMMessageData).insert(
      IMMessageDataCompanion.insert(
        size: imMsg.size, 
        msgId: imMsg.msgId, 
        fromId: imMsg.fromId, 
        toId: imMsg.toId, 
        createTime: imMsg.createTime, 
        updateTime: imMsg.updateTime, 
        imMsgType: imMsg.imMsgType, 
        sessionType: imMsg.sessionType, 
        msgState: imMsg.msgState, 
        readState: imMsg.readState, 
        fromClient: imMsg.fromClient, 
        toClient: imMsg.toClient, 
        content: Value(imMsg.content),
        url: Value(imMsg.url),
        attachState: imMsg.attachState,
        attachInfo: Value(imMsg.attachInfo),
        localPath: Value(imMsg.localPath),
        custom: Value(imMsg.custom),
        isReceived: imMsg.isReceived?1:0
      )
    );
  }

  Future<List<IMMessage>> queryAllIMMessage() async{
    List<IMMessageDataData> queryResultSet = await select(iMMessageData).get();
    List<IMMessage> list = [];

    for(var query in queryResultSet){
      list.add(convertImQueryToImmessage(query));
    }//end for each
    return list;
  }

  IMMessage convertImQueryToImmessage(IMMessageDataData query){
    final IMMessage msg = IMMessage();
    
    msg.id = query.id;
    msg.size = query.size;
    msg.msgId = query.msgId;
    msg.fromId = query.fromId;
    msg.toId = query.toId;
    msg.createTime = query.createTime;
    msg.updateTime = query.updateTime;

    msg.imMsgType = query.imMsgType;
    msg.sessionType = query.sessionType;
    msg.msgState = query.msgState;
    msg.readState = query.readState;
    msg.fromClient = query.fromClient;
    msg.toClient = query.toClient;

    msg.content = query.content;
    msg.url = query.url;
    msg.attachState = query.attachState;
    msg.attachInfo = query.attachInfo;
    msg.localPath = query.localPath;
    msg.custom = query.custom;

    msg.isReceived = query.isReceived == 1;
    return msg;
  }
}

