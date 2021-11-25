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
  String mClientStatus = "init";

  String mIncomingMessage = "";

  StateChangeCallback? _stateChangeCallback;

  IMMessageIncomingCallback? _imMessageIncomingCallback;

  late TextEditingController _editController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _editController = TextEditingController(text: "你好世界");
    _focusNode = FocusNode();
    
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

    _imMessageIncomingCallback??=(incomingIMMessageList){
       setState(() {
        mIncomingMessage = incomingIMMessageList.first.content!;
      });
    };

    IMClient.getInstance()?.registerIMMessageIncomingObserver(_imMessageIncomingCallback!, true);
  }

  void login(int uid){
    String token = "fuckali_$uid";

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
          child: SizedBox(
            width: 320,
            child: ListView(
              children: <Widget>[
                  Text("status: $mClientStatus  uid: ${IMClient.getInstance()?.uid}"),
                  ElevatedButton(
                  onPressed: ()=> login(1), 
                  child: const Text("登录1"),
                  ),
                  const SizedBox(height: 20,),
                  ElevatedButton(
                  onPressed: ()=> login(1001), 
                  child: const Text("登录1001"),
                  ),
                  const SizedBox(height: 20,),
                  SizedBox(
                    width: 200,
                    child: TextField(
                      controller: _editController, 
                      style:const TextStyle(
                        color: Colors.black,
                        fontSize: 18.0,
                      ), 
                      cursorColor: Colors.black, 
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      focusNode: _focusNode,
                    ),
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
                  const SizedBox(height: 20,),
                  Text("接收消息 : $mIncomingMessage"),
              ],
            ),
          )
        ),
      )
    );
  }

  @override
  void dispose() {
    _editController.dispose();
    _focusNode.dispose();
    IMClient.getInstance()?.dispose();
    super.dispose();
  }

  void imLogout(){
    IMClient.getInstance()?.imLoginOut(loginOutCallback:(r){
      LogUtil.log("退出登录: ${r.result}");
    });
  }

  void sendTextMessage(int toId){
    String content = _editController.text;

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


