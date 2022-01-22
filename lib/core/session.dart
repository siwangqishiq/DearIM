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
    if (msg.isReceived) {
      unreadCount += msg.readState;
    }
  }
}

typedef RecentSessionChangeCallback = Function(List<RecentSession> sessionList);

// 会话管理
class SessionManager {
  int _uid = -1;

  int get uid => _uid;

  final List<RecentSession> _recentSessionList = <RecentSession>[];

  final Map<String, RecentSession> _recentSessionMap =
      <String, RecentSession>{};

  final List<RecentSessionChangeCallback> _changeCallbackList =
      <RecentSessionChangeCallback>[];

  //EasyStore? _store;

  IMDatabase? imDb;

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

    //open 
    await _openDatabase();

    //
    _queryAllIMMessages();
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
  void _queryAllIMMessages() async{
    List<IMMessage> list = await imDb?.queryAllIMMessage()??[];   
    _rebuildRecentSession(list);
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

  //接收新的IM消息
  void onReceivedIMMessage(final IMMessage msg){
    _updateRecentSession(msg, recentSort: true, fireCallback: true);

    //保存消息到本地
    // _store?.save(msg);
    imDb?.saveIMMessage(msg);
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
  void _updateRecentSession(final IMMessage msg,
      {bool recentSort = false, bool fireCallback = false}) {
    final String key = _getRecentSessionKey(msg);

    if (_recentSessionMap.containsKey(key)) {
      //已经包含
      final RecentSession recent = _recentSessionMap[key]!;
      addIMMessageByUpdateTime(recent.imMsgList, msg);

      recent.updateUnReadCount(msg);
    } else {
      final RecentSession recent = RecentSession();
      recent.sessionId = msg.sessionId;
      recent.sessionType = msg.sessionType;
      recent.imMsgList.add(msg);
      recent.unreadCount += msg.readState;

      _recentSessionMap[key] = recent;
      _recentSessionList.add(recent);

      recent.updateUnReadCount(msg);
    }

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
