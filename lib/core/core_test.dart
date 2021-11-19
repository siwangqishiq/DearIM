import 'package:dearim/core/log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'imcore.dart';

///
/// core测试相关
///
///
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
  @override
  void initState() {
    super.initState();
    initIM();
  }

  //im client test
  void initIM() {
    int uid = 1001;
    String token =
        "eyJ0eXAiOiJKV1QiLCJfdWlkIjoiMTAwMSIsImFsZyI6IkhTMjU2In0.eyJleHAiOjE2MzcyODIxMzF9.nOeb6UDybwFv_VDi9NnGdrwalZsw1wExpJp4AxsFPlQ";
    IMClient.getInstance()?.registerStateObserver((oldState, newState) {
      LogUtil.log("change state $oldState to $newState");
    }, true);

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
                const Text("Hello IMClient"),
                ElevatedButton(
                 onPressed: ()=> initIM(), 
                 child: const Text("登录"),
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
}

class TestCoreMain extends StatefulWidget{
  const TestCoreMain({Key? key}) : super(key: key);

  @override
  TestCoreMainState createState() => TestCoreMainState();
}


