import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/session.dart';
import 'package:dearim/core/utils.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/user/contacts.dart';
import 'package:dearim/utils/timer_utils.dart';
import 'package:dearim/views/head_view.dart';
import 'package:dearim/widget/emoji.dart';
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

  VoidCallback? _contactChangeCallback;

  @override
  void initState() {
    super.initState();

    recentSessionList = IMClient.getInstance().findRecentSessionList();
    _recentSessionChangeCallback = (List<RecentSession> sessionList){
      LogUtil.log("最近会话变更: ${sessionList.length}");
      setState(() {
        recentSessionList = sessionList;
      });
    };
    
    IMClient.getInstance().registerRecentSessionObserver(_recentSessionChangeCallback, true);

    _contactChangeCallback = (){
      setState(() {
      });
    };
    ContactsDataCache.instance.addListener(_contactChangeCallback!);
  }
  
  @override
  Widget build(BuildContext context) {
    LogUtil.log("最近联系人刷新 数量:${recentSessionList?.length}");
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
    int unreadCount =  recentSession.unreadCount;
    if(unreadCount > 99){
      unreadCount = 99;
    }

    return InkWell(
      onTap: () async{
        if(contact == null){
          return;
        }

        await Navigator.of(context).push(
          PageRouteBuilder(
            pageBuilder: (_,__,___) => ChatPage(contact , sessionType: recentSession.sessionType)
          ),
        );

        //refresh
        setState(() {
        });
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Column(
            children: [
              SizedBox(
                height: 80,
              child: Row(
                children: [
                  //头像
                  Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(5),
                        child: HeadView(
                          avatar , 
                          size:ImageSize.small,
                          circle: 16,
                          height: 55,
                          width: 55,
                        ),
                      ),
                      sessionUnreadCountWidget(recentSession),
                      platformIcon(recentSession)
                    ],
                  ),
                  const SizedBox(width: 10,),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name , style:const TextStyle(color: Colors.black , fontSize: 18.0),maxLines: 1),
                        EmojiText(content , style:const TextStyle(color: Colors.grey , fontSize: 14.0), maxLines: 1,),
                      ],
                    )
                  ),
                  Text(
                    TimerUtils.getMessageFormatTime(sessionTime , detailShow: false) , 
                    style:const TextStyle(color: Colors.grey , fontSize: 12.0),
                  )
                ],
              ),
            ),
            const Divider(height: 0.5,color: Colors.grey,)
          ],
        ), 
      ),
    );
  }

  ///
  /// 显示会话最近未读消息的发送平台
  ///
  Widget platformIcon(RecentSession recentSession){
    int clientType = recentSession.lastIMMessage?.fromClient??ClientType.Android;
    return Positioned(
      right: 0,
      bottom: 0,
      child: Visibility(
        child: Image.asset(_findPlatformIcon(clientType) , width: 20, height: 20),
        maintainSize: true, 
        maintainAnimation: true,
        maintainState: true,
        visible: recentSession.unreadCount > 0, 
      )
    );
  }

  ///
  /// 根据类型 获得平台操作系统文件名
  ///
  String _findPlatformIcon(int type){
    String filename = "";
    switch(type){
      case ClientType.Android:
        filename = "ic_android.png";
        break;
      case ClientType.Ios:
        filename = "ic_ios.png";
        break;
      case ClientType.Web:
        filename = "ic_server.png";
        break;
      case ClientType.Linux:
        filename = "ic_linux.png";
        break;
      case ClientType.Macos:
        filename = "ic_mac.png";
        break;
      case ClientType.Windows:
        filename = "ic_windows.png";
        break;
       default:
        filename = "ic_server.png";
        break;
    }//end switch

    return filename;
  }

  Widget sessionUnreadCountWidget(RecentSession recentSession){
    int unreadCount = recentSession.unreadCount;
    if(unreadCount > 99){
      unreadCount = 99;
    }
    return Positioned(
      child: AnimatedContainer(
        duration:const Duration(milliseconds: 100),
        width: unreadCount >0?25:0,
        height: unreadCount >0?25:0,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle
        ),
        child: Center(
          child: Text(
            unreadCount.toString(), 
            style: const TextStyle(color: Colors.white , fontSize: 16)
          )
        ),
      ),
      top: 0,
      right: 0,
    );
  }

  @override
  void dispose() {
    if(_contactChangeCallback != null){
      ContactsDataCache.instance.removeListener(_contactChangeCallback!);
    }
    IMClient.getInstance().registerRecentSessionObserver(_recentSessionChangeCallback, false);
    super.dispose();
  }
}
