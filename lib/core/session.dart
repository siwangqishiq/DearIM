import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';

///
///会话
///

//最近会话
class RecentSession{
  int sessionId = 0;//会话ID
  int sessionType = IMMessageSessionType.P2P;//会话类型
  int time = 0;//
  int unreadCount = 0;//会话未读数量
  IMMessage? imMessage;//最近的一条消息
  String? custom;//用户自定义数据
}

// 会话管理
class SessionManager{
  int _uid = -1;

  int get uid => uid;

  SessionManager(id){
    _uid = id;
    _buildRecentSession(_loadHistoryIMMessage());
  }

  List<IMMessage> _loadHistoryIMMessage(){
    //载入历史消息
    return <IMMessage>[];
  }

  void _buildRecentSession(List<IMMessage> msgList){

  }


  void dispose(){

  }
}