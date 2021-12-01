import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/session.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/utils/timer_utils.dart';
import 'package:dearim/views/head_view.dart';
import 'package:flutter/material.dart';

import 'chat_page.dart';

///
///会话列表
///
class SessionPage extends StatelessWidget{
  const SessionPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     body: Column(
       children: const [
         ClientStatusPanelWidget(),
         RecentSessionListWidget()
       ],
     ),
   );
  }
}

class ClientStatusPanelWidget extends StatefulWidget{
  const ClientStatusPanelWidget({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return ClientStatusState();
  }
}

class ClientStatusState extends State<ClientStatusPanelWidget>{
  String? _clientStatus;
  bool _clientStatusError = false;

  late StateChangeCallback _clientStateCallback;

  @override
  void initState() {
    super.initState();

    _loadStatus();

    _clientStateCallback = (oldState , newState){
      _loadStatus();
      setState(() {
      });
    };
    IMClient.getInstance().registerStateObserver(_clientStateCallback, true);
  }

  void _loadStatus(){
    ClientState clientState = IMClient.getInstance().state;
    if(clientState == ClientState.logined){
      _clientStatusError = false;
    }else{
      switch(clientState){
        case ClientState.connecting:
        _clientStatus = "连接中";
        break;
        case ClientState.loging:
        _clientStatus = "登录中";
        break;
        case ClientState.logouting:
        _clientStatus = "注销中";
        break;
        case ClientState.unconnect:
        _clientStatus = "未连接";
        break;
        default:
          break;
      }
      _clientStatusError = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Visibility(
      child: Container(
        height: 30,
        width: double.infinity,
        color: Colors.redAccent,
        child: Center(
            child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            child: Text(_clientStatus??"" , style:const TextStyle(color: Colors.white),), 
          ),
        ),
      ),
      visible: _clientStatusError,
    );
  }

  @override
  void dispose() {
    IMClient.getInstance().registerStateObserver(_clientStateCallback, false);
    super.dispose();
  }
}

// ignore: must_be_immutable
class RecentSessionListWidget extends StatefulWidget {
  const RecentSessionListWidget({Key? key}) : super(key: key);

  @override
  RecentSessionListState createState() => RecentSessionListState();
}

class RecentSessionListState extends State<RecentSessionListWidget> {
  List<RecentSession>? recentSessionList;

  late RecentSessionChangeCallback _recentSessionChangeCallback;

  @override
  void initState() {
    super.initState();
    LogUtil.log("最近会话列表 initState");

    recentSessionList = IMClient.getInstance().findRecentSessionList();
    _recentSessionChangeCallback = (List<RecentSession> sessionList){
      setState(() {
        LogUtil.log("最近会话列表更新");
        recentSessionList = sessionList;
      });
    };
    
    IMClient.getInstance().registerRecentSessionObserver(_recentSessionChangeCallback, true);
  }
  
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount:recentSessionList?.length??0,
        itemBuilder: (BuildContext context, int index) => buildRecentSessionItem(context , index)
      )
    );
  }

  Widget buildRecentSessionItem(BuildContext context , int pos){
    final RecentSession recentSession = recentSessionList![pos];

    ContactModel? contact = ContactsDataCache.instance.getContact(recentSession.sessionId);

    final String name = contact?.name??"";
    final String avatar = contact?.avatar??"";
    final String content = recentSession.lastIMMessage?.content??"";
    final int sessionTime = recentSession.time;

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
      child: Column(
          children: [
            SizedBox(
              height: 70,
            child: Row(
              children: [
                //头像
                HeadView(
                  avatar , 
                  size:ImageSize.small,
                  circle: 16,
                  height: 55,
                  width: 55,
                ),
                const SizedBox(width: 10,),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name , style:const TextStyle(color: Colors.black , fontSize: 18.0),maxLines: 1),
                      Text(content , style:const TextStyle(color: Colors.grey , fontSize: 14.0),maxLines: 1,),
                    ],
                  )
                ),
                Text(
                  TimerUtils.getMessageFormatTime(sessionTime) , 
                  style:const TextStyle(color: Colors.grey , fontSize: 12.0),
                )
              ],
            ),
          ),
          const Divider(height: 0.5,color: Colors.grey,)
        ],
      ), 
    );
  }

  @override
  void dispose() {
    IMClient.getInstance().registerRecentSessionObserver(_recentSessionChangeCallback, false);
    super.dispose();
  }
}
