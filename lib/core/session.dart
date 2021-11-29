import 'dart:collection';

import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';

import 'utils.dart';

///
///会话
///

//最近会话
class RecentSession {
  int sessionId = 0;//会话ID
  int sessionType = IMMessageSessionType.P2P;//会话类型
  
  int unreadCount = 0;//会话未读数量
  List<IMMessage> imMsgList = <IMMessage>[];//消息列表
  String? custom;//用户自定义数据
  String? attach;//附件信息

  //最近IM消息消息
  IMMessage? get lastIMMessage => imMsgList.last;

  //会话时间
  int get time => (lastIMMessage?.updateTime)??-1;

  //更新session未读数量
  void updateUnReadCount(IMMessage msg){
    if(msg.isReceived){
      unreadCount += msg.readState;
    }
  }
}

typedef RecentSessionChangeCallback = Function(List<RecentSession> sessionList);

// 会话管理
class SessionManager{
  int _uid = -1;

  int get uid => _uid;

  final List<RecentSession> _recentSessionList = <RecentSession>[];

  final Map<String , RecentSession> _recentSessionMap =<String , RecentSession>{};

  final List<RecentSessionChangeCallback> _changeCallbackList = <RecentSessionChangeCallback>[];

  SessionManager(id){
    _uid = id;
    loadData();
  }

  void loadData() async {
    List<IMMessage> list = await _loadHistoryIMMessage();
    _rebuildRecentSession(list);
  }

  //获取最近消息列表
  List<RecentSession> findRecentSessionList(){
    return _recentSessionList;
  }

  //查询用户IM消息列表
  List<IMMessage> queryIMMessageByUid(int sessionType ,int sessionId){
    final String key = "${sessionType}_$sessionId";
    return _recentSessionMap[key]?.imMsgList??[];
  }

  Future<List<IMMessage>> _loadHistoryIMMessage() async{
    //载入历史消息
    return <IMMessage>[];
  }

  //注册 或 解绑 状态改变事件监听
  bool registerStateObserver(RecentSessionChangeCallback callback, bool register) {
    if (register) {
      //注册
      if (!Utils.listContainObj(_changeCallbackList, callback)) {
        _changeCallbackList.add(callback);
        return true;
      }
    } else {
      //解绑
      if (Utils.listContainObj(_changeCallbackList, callback)) {
        _changeCallbackList.remove(callback);
        return true;
      }
    }
    return false;
  }

  //重构会话列表
  void _rebuildRecentSession(List<IMMessage> msgList){
    _recentSessionList.clear();
    _recentSessionMap.clear();

    for(final IMMessage msg in msgList){
      updateRecentSession(msg);
    }//end for each

    _sortRecentSessionList();
  }

  void _fireRecentChangeCallback(){
    for(RecentSessionChangeCallback callback in _changeCallbackList){
      callback.call(findRecentSessionList());
    }
  }

  ///
  ///通过消息 更新最近联系人会话
  ///
  void updateRecentSession(final IMMessage msg , {bool recentSort = false , bool fireCallback = false}){
    final String key = _getRecentSessionKey(msg);

    if(_recentSessionMap.containsKey(key)){//已经包含
      final RecentSession recent = _recentSessionMap[key]!;
      addIMMessageByUpdateTime(recent.imMsgList , msg);

      recent.updateUnReadCount(msg);
    }else{
      final RecentSession recent = RecentSession();
      recent.sessionId = msg.sessionId;
      recent.sessionType = msg.sessionType;
      recent.imMsgList.add(msg);
      recent.unreadCount += msg.readState;

      _recentSessionMap[key] = recent;
      _recentSessionList.add(recent);

      recent.updateUnReadCount(msg);
    }

    if(recentSort){//重新排序
      _sortRecentSessionList();
    }

    if(fireCallback){
      _fireRecentChangeCallback();
    }
  }

  //删除消息 session更新
  void onRemoveIMMessage(final IMMessage msg){
    final String key = _getRecentSessionKey(msg);
    if(_recentSessionMap.containsKey(key)){
      final RecentSession recent = _recentSessionMap[key]!;
      recent.imMsgList.remove(msg);

      _sortRecentSessionList();
      _fireRecentChangeCallback();
    }
  }

  void _sortRecentSessionList(){
    _recentSessionList.sort((left , right){
      return left.time - right.time;
    });
  }

  static void addIMMessageByUpdateTime(List<IMMessage> list , IMMessage msg){
    // for(int i = list.length - 1 ; i>= 0 ;i++){
    //   if(msg.updateTime > list[i].updateTime){
    //     list.insert(i + 1, msg);
    //     return;
    //   }
    // }//end for i
    // list.insert(0, msg);

    list.add(msg);
    list.sort((left , right){
      return left.updateTime - right.updateTime;
    });
  }

  //快速检索数据
  String _getRecentSessionKey(IMMessage message){
    return "${message.sessionType}_${message.sessionId}";
  }


  //关闭
  void dispose(){

  }
}