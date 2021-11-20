import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'imcore.dart';
import 'utils.dart';

///
/// core测试相关
///
void coreTestRun(){
  runApp(const CoreTestApp());
}

class CoreTestApp extends StatelessWidget {
  const CoreTestApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'dearIM',
      debugShowCheckedModeBanner: true,
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TestCoreMain(),
    );
  }
}


class TestCoreMainState extends State<TestCoreMain>{
  String mClientStatus = "";

  StateChangeCallback? _stateChangeCallback;

  @override
  void initState() {
    super.initState();
    initIM();
  }

  //im client test
  void initIM() {
    _stateChangeCallback ??= (oldState, newState) {
      LogUtil.log("change state $oldState to $newState");

      setState(() {
        mClientStatus = newState.toString();
      });
    };

    IMClient.getInstance()?.registerStateObserver(_stateChangeCallback!, true);
  }

  void login1001(){
    int uid = 1001;
    String token = "eyJ0eXAiOiJKV1QiLCJfdWlkIjoiMTAwMSIsImFsZyI6IkhTMjU2In0.eyJleHAiOjE2Mzg4NjUwNTB9.6nYrxzog2bTRVkC5xUf_7qOeUJAE5Q4Vvf__4sPlbIk";

    IMClient.getInstance()?.imLogin(uid, token, loginCallback: (result) {
      if (result.result) {
        LogUtil.log("IM登录成功");
      } else {
        LogUtil.log("IM登录失败 原因: ${result.reason}");
      }
    });
  }

  void login1(){
    int uid = 1;
    String token = "eyJ0eXAiOiJKV1QiLCJfdWlkIjoiMSIsImFsZyI6IkhTMjU2In0.eyJleHAiOjE2Mzg4NzA4NzJ9.fPfkY8h37LNKxICpq_45ZubNc6GznIs1GZM057N2m9Y";

    IMClient.getInstance()?.imLogin(uid, token, loginCallback: (result) {
      if (result.result) {
        LogUtil.log("IM登录成功");
      } else {
        LogUtil.log("IM登录失败 原因: ${result.reason}");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "TestCore",
          style: TextStyle(color: Colors.white),
        ),
      ),
      // ignore: avoid_unnecessary_containers
      body: Container(
        child:Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
                Text("当前状态: $mClientStatus  uid: ${IMClient.getInstance()?.uid}"),
                ElevatedButton(
                 onPressed: ()=> login1(), 
                 child: const Text("登录1"),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                 onPressed: ()=> login1001(), 
                 child: const Text("登录1001"),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                 onPressed: ()=> sendTextMessage(1), 
                 child: const Text("发送文本消息给1"),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                 onPressed: ()=> sendTextMessage(1001), 
                 child: const Text("发送文本消息给1001"),
                ),
                const SizedBox(height: 20,),
                ElevatedButton(
                 onPressed: ()=> imLogout(), 
                 child: const Text("退出IM登录"),
                ),
            ],
          ),
        ),
      )
    );
  }

  void imLogout(){
    IMClient.getInstance()?.imLoginOut(loginOutCallback:(r){
      LogUtil.log("退出登录: ${r.result}");
    });
  }

  void sendTextMessage(int toId){
    String content = "你好 世界 时间:${Utils.currentTime()}";

    IMMessage? msg = IMMessageBuilder.createText(toId, IMMessageSessionType.P2P, content);
    if(msg != null){
      IMClient.getInstance()?.sendIMMessage(msg , callback : (imMessage , result){
        LogUtil.log("send im message ${result.code}");
      });
    }
  }
}

class TestCoreMain extends StatefulWidget{
  const TestCoreMain({Key? key}) : super(key: key);

  @override
  TestCoreMainState createState() => TestCoreMainState();
}


