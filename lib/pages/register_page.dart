// ignore_for_file: file_names
import 'package:dearim/core/file_upload.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/protocol.dart';
import 'package:dearim/core/utils.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:dearim/views/head_view.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key}) : super(key: key);

  @override
  _RegisterPageState createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  String? _avatar;
  String? _username;
  String? _password;
  String? _confirmPassword;
  String? _nickname;

  late FileUploadManager fileUploadManager;

  @override
  void initState() {
    super.initState();
    fileUploadManager = DefaultFileUploadManager();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "注册",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const TextField(
                decoration: InputDecoration(hintText: "用户名(必填)"),
              ),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: "密码(必填)"),
                obscureText: true,
              ),
              const TextField(
                decoration: InputDecoration(hintText: "确认密码(必填)"),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              const TextField(
                decoration: InputDecoration(hintText: "昵称(必填)"),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.topLeft,
                child: Text("头像:"),
              ),
              InkWell(
                onTap: ()=> pickAvatar(),
                child: HeadView(_avatar ,size: ImageSize.origin, width: 128, height:128 , key: UniqueKey(),),
              ),
              const SizedBox(height: 8 , ),
              MaterialButton(
                onPressed: () {
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    width: 400,
                    height: 40,
                    color: ColorThemes.themeColor,
                    child: const Center(
                      child: Text(
                        "注册账户",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
              )
            ],
          ),
        ),
      )
    );
  }

  void pickAvatar() async{
    FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.image);

    if(pickerResult != null){
      LogUtil.log("用户选择文件 ${pickerResult.files.single.path}");
      String? path = pickerResult.files.single.path;
      
      fileUploadManager.uploadFile(path!, UploadFileType.image, (result, url, attach){
        LogUtil.log("result = $result");
        if(result == Codes.success){
          LogUtil.log("url = $url");
          setState(() {
            _avatar = url;
          });
        }
      });
    }else{
      LogUtil.log("用户选择取消");
    }
  }
}
