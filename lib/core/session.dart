import 'dart:collection';
import 'dart:ffi';
import 'dart:io';

import 'package:dearim/core/estore/estore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';

import 'estore/im_table.dart';
import 'utils.dart';
import 'package:sqlite3/open.dart';

///
///会话
///

//最近会话
class RecentSession {
  int sessionId = 0; //会话ID
  int sessionType = IMMessageSessionType.P2P; //会话类型

  int unreadCount = 0; //会话未读数量
  List<IMMessage> imMsgList = <IMMessage>[]; //消息列表
  String? custom; //用户自定义数据
  String? attach; //附件信息

  //最近IM消息消息
  IMMessage? get lastIMMessage => imMsgList.last;

  //会话时间
  int get time => (lastIMMessage?.updateTime) ?? -1;

  //更新session未读数量
  void updateUnReadCount(IMMessage msg) {
    // if (msg.isReceived) {
    //   unreadCount += msg.readState;
    // }
  }
}

//未读消息记录
class UnreadSession {
  int sessionType = -1;
  int sessionId = -1;
  int unreadCount = 0;
  String? custom;

  UnreadSession();

  factory UnreadSession.build(int type , int id , int count){
    UnreadSession result = UnreadSession();
    result.sessionType = type;
    result.sessionId = id;
    result.unreadCount = count;
    return result;
  }

  String get key => genKey(sessionType , sessionId);

  static String genKey(int type , int id) => "$type/$id";
}

typedef RecentSessionChangeCallback = Function(List<RecentSession> sessionList);

//未读数量改变回调
typedef UnreadCountChangeCallback = Function(int oldUnreadCunt , int currentUnreadCount);

// 会话管理
class SessionManager {
  int _uid = -1;

  int get uid => _uid;

  final List<RecentSession> _recentSessionList = <RecentSession>[];

  final List<UnreadCountChangeCallback> _unreadCountChangeCallbackList = <UnreadCountChangeCallback>[];

  final Map<String, RecentSession> _recentSessionMap =
      <String, RecentSession>{};

  final List<RecentSessionChangeCallback> _changeCallbackList =
      <RecentSessionChangeCallback>[];

  //EasyStore? _store;

  IMDatabase? imDb;

  //总未读数
  int totalUnreadCount = 0;

  final Map<String , UnreadSession> unreadSessionData = <String , UnreadSession>{};

  SessionManager(){
    open.overrideFor(OperatingSystem.windows, _openOnWindows);
  }

  Future<int> loadUid(int id) async{
    //debug 模拟加载不出最近联系人场景
    // LogUtil.log("session loadData delay $id");
    // await Future.delayed(const Duration(seconds: 5));
    // LogUtil.log("session loadData delay fininsh $id");

    //uid
    _uid = id;

    loadData();
    return Future.value(0);
  }

  void loadData() async {
    // _store = EasyStore.open("${_uid}db");
    // await _store!.init();
    
    // List<dynamic> list = _store!.query(IMMessage());
    // LogUtil.log("用户$_uid 查询本地历史消息 ${list.length}条记录");

    //open 打开数据库 
    await _openDatabase();
    //查询历史消息 生成最近会话列表
    var msgList = await _queryAllIMMessages();
    //查询未读
    await _queryAllUnreadData();

    //
    _rebuildRecentSession(msgList);

    //
    _updateAndFireCbUnreadSessionData();
  }

  //打开本地数据库
  Future<int> _openDatabase() async{
    //关闭之前打开的db
    if(imDb != null && imDb?.uid != _uid){
      await imDb?.close();
    }

    imDb = IMDatabase(_uid); 
    return Future.value(0);
  } 

  //查询所有的IM消息  
  //todo 需要优化
  Future<List<IMMessage>> _queryAllIMMessages() async{
    List<IMMessage> list = await imDb?.queryAllIMMessage()??[];   
    return list;
  }

  //查询未读会话数量记录
  Future<int> _queryAllUnreadData() async{
    List<UnreadSession> list = await (imDb?.queryAllUnreadSessionRecords())??[];
    unreadSessionData.clear();
    for(var record in list){
      if(record.sessionType < 0 || record.sessionId < 0){
        continue;
      }
      unreadSessionData[record.key] = record;
    }    
    return Future.value(0);
  }

  ///
  /// 查询会话未读消息数量
  ///
  int querySessionUnreadCount(int sessionType , int sessionId){
    return (unreadSessionData[UnreadSession.genKey(sessionType, sessionId)]?.unreadCount)??0;
  }

  //windows上打开sqlite
  DynamicLibrary _openOnWindows(){
    final scriptDir = File(Platform.script.toFilePath()).parent;
    final libraryNextToScript = File('${scriptDir.path}\\sqlite3.dll');
    //print("libraryNextToScript : ${libraryNextToScript.path}");
    return DynamicLibrary.open(libraryNextToScript.path);
  }

  //获取最近消息列表
  List<RecentSession> findRecentSessionList() {
    return _recentSessionList;
  }

  //查询用户IM消息列表
  List<IMMessage> queryIMMessageByUid(int sessionType, int sessionId) {
    final String key = "${sessionType}_$sessionId";
    LogUtil.log("查询消息记录 key : $key");
    var result = _recentSessionMap[key]?.imMsgList ?? [];

    // LogUtil.log("历史消息查询结果:");
    // for(IMMessage msg in result){
    //   LogUtil.log("${msg.sessionId} : ${msg.content}");
    // }
    // LogUtil.log("历史消息查询结果:END");
    return result;
  }

  ///
  /// 注册/解绑未读消息改变 观察者
  ///
  bool registerUnreadChangeObserver(UnreadCountChangeCallback callback , bool register){
    if (register) {
      //注册
      if (!Utils.listContainObj(_unreadCountChangeCallbackList, callback)) {
        _unreadCountChangeCallbackList.add(callback);
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_unreadCountChangeCallbackList, callback)) {
        _unreadCountChangeCallbackList.remove(callback);
        return true;
      }
    }
    return false;
  }

  //注册 或 解绑 状态改变事件监听
  bool registerRecentSessionObserver(
      RecentSessionChangeCallback callback, bool register) {
    if (register) {
      //注册
      if (!Utils.listContainObj(_changeCallbackList, callback)) {
        _changeCallbackList.add(callback);
        LogUtil.log("添加最近会话 Ok ${_changeCallbackList.length}");
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_changeCallbackList, callback)) {
        _changeCallbackList.remove(callback);
        LogUtil.log("解绑最近会话 Ok ${_changeCallbackList.length}");
        return true;
      }
    }
    return false;
  }

  //重构会话列表
  void _rebuildRecentSession(List<IMMessage> msgList) {
    _recentSessionList.clear();
    _recentSessionMap.clear();

    for (final IMMessage msg in msgList) {
      _updateRecentSession(msg);
    } //end for each

    _sortRecentSessionList();

    //触发回调
    _fireRecentChangeCallback();
  }

  void _fireRecentChangeCallback() {
    for (RecentSessionChangeCallback callback in _changeCallbackList) {
      callback.call(findRecentSessionList());
    }
  }

  //增加未读消息数
  void _incrementUnreadRecord(IMMessage msg){
    final String key = UnreadSession.genKey(msg.sessionType, msg.sessionId);
    UnreadSession? unreadRecord = unreadSessionData[key];
    bool isCreate = false;
    if(unreadSessionData[key] == null){
      unreadRecord = UnreadSession.build(msg.sessionType, msg.sessionId, 0);
      unreadSessionData[unreadRecord.key] = unreadRecord;
      isCreate = true;
    }

    unreadRecord?.unreadCount++;

    //持久化保存
    if(isCreate){
      imDb?.insertUnreadCountSession(unreadRecord!);
    }else{
      imDb?.updateUnreadCountSession(unreadRecord!);
    }
  }

  

  ///
  /// 根据会话类型 清理未读消息
  ///
  void clearUnreadCountBySession(int sessionType , int sessionId){
    final String key = UnreadSession.genKey(sessionType, sessionId);
    UnreadSession? unreadRecord = unreadSessionData[key];

    if(unreadRecord == null){
      return;
    }

    //此会话下的未读消息 清空为0
    unreadRecord.unreadCount = 0;
    _updateAndFireCbUnreadSessionData();

    //更新最近会话列表
    final String sessionKey = "${sessionType}_$sessionId";
    //LogUtil.log("根据会话类型 清理未读消息 $sessionKey");
    _recentSessionMap[sessionKey]?.unreadCount = querySessionUnreadCount(unreadRecord.sessionType, unreadRecord.sessionId);
    //LogUtil.log("根据会话类型 清理未读消息222 ${_recentSessionMap[sessionKey]?.unreadCount}");

    //callback
    // _fireRecentChangeCallback();

    //持久化保存
    imDb?.updateUnreadCountSession(unreadRecord);
  }

  //接收新的IM消息
  void onReceivedIMMessage(final IMMessage msg){
    //更新未读数据
    _incrementUnreadRecord(msg);

    _updateRecentSession(msg, recentSort: true, fireCallback: true);

    //保存消息到本地
    // _store?.save(msg);
    imDb?.saveIMMessage(msg);

    _updateAndFireCbUnreadSessionData();
  }

  ///
  /// 更新未读数量 触发回调
  ///
  void _updateAndFireCbUnreadSessionData(){
    //统计未读总数量
    int total = 0;
    for(var key in _recentSessionMap.keys){
      RecentSession recentSession = _recentSessionMap[key]!;
      total += recentSession.unreadCount;
    }//end for each

    LogUtil.log("未读数修改: old = $totalUnreadCount new = $total");
    int oldUnreadCount = totalUnreadCount;
    totalUnreadCount = total;
    if(totalUnreadCount != oldUnreadCount){
      for(var cb in _unreadCountChangeCallbackList){
        cb.call(oldUnreadCount , totalUnreadCount);
      }//end for each
    }
  }

  //发送新IM消息
  void onSendIMMessage(final IMMessage msg , {bool saveLocal = true}){
    _updateRecentSession(msg,recentSort: true, fireCallback: true);

    //保存消息到本地
    if(saveLocal){
      // _store?.save(msg);
      imDb?.saveIMMessage(msg);
    }
  }

  ///
  ///通过消息 更新最近联系人会话
  ///
  RecentSession _updateRecentSession(final IMMessage msg,
      {bool recentSort = false, bool fireCallback = false}) {
    final String key = _getRecentSessionKey(msg);

    final RecentSession recent;
    if (_recentSessionMap.containsKey(key)) {
      //已经包含
      recent = _recentSessionMap[key]!;
      addIMMessageByUpdateTime(recent.imMsgList, msg);

      recent.updateUnReadCount(msg);
    } else {
      recent = RecentSession();
      recent.sessionId = msg.sessionId;
      recent.sessionType = msg.sessionType;
      recent.imMsgList.add(msg);
      recent.unreadCount += msg.readState;

      _recentSessionMap[key] = recent;
      _recentSessionList.add(recent);

      recent.updateUnReadCount(msg);
    }

    //更新未读数量
    recent.unreadCount = querySessionUnreadCount(recent.sessionType, recent.sessionId);

    if (recentSort) {
      //重新排序
      _sortRecentSessionList();
    }

    //debug show
    // LogUtil.log("--------beg-------");
    // for(int i = 0 ; i < _recentSessionList.length ;i++){
    //   var data = _recentSessionList[i];
    //   LogUtil.log("sessionI ${data.sessionId} msg content: ${data.lastIMMessage?.content} count: ${data.imMsgList.length}");
    // }
    // LogUtil.log("--------end-------");

    if (fireCallback) {
      _fireRecentChangeCallback();
    }
    return recent;
  }

  //删除消息 session更新
  void onRemoveIMMessage(final IMMessage msg) {
    final String key = _getRecentSessionKey(msg);
    if (_recentSessionMap.containsKey(key)) {
      final RecentSession recent = _recentSessionMap[key]!;
      recent.imMsgList.remove(msg);

      _sortRecentSessionList();
      _fireRecentChangeCallback();
    }
  }

  //重新排序会话列表
  void _sortRecentSessionList() {
    _recentSessionList.sort((left, right) {
      return right.time - left.time;
    });
  }

  static void addIMMessageByUpdateTime(List<IMMessage> list, IMMessage msg) {
    // for(int i = list.length - 1 ; i>= 0 ;i++){
    //   if(msg.updateTime > list[i].updateTime){
    //     list.insert(i + 1, msg);
    //     return;
    //   }
    // }//end for i
    // list.insert(0, msg);

    list.add(msg);
    list.sort((left, right) {
      return left.updateTime - right.updateTime;
    });
  }

  //快速检索数据
  String _getRecentSessionKey(IMMessage message) {
    return "${message.sessionType}_${message.sessionId}";
  }

  //关闭
  void dispose() {
    _recentSessionList.clear();
  }
}
