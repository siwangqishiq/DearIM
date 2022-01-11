// ignore_for_file: constant_identifier_names

import 'package:dearim/core/log.dart';
import 'package:dearim/pages/chat_page.dart';
import 'package:dearim/pages/explorer_image.dart';
import 'package:dearim/views/image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

///
/// 输入框 更多操作
///
class InputAction {
  final String name;
  final String icon;
  late int id = -1;

  InputAction(this.id, this.name, this.icon);

  void onClickAction(BuildContext context , InputPanelState inputPanel) {
    //base class do nothing
  }
}

class InputActionHelper {
  static const int PICK_IMAGE_ABLUM = 1;

  //面板每页的数据项
  static const int PAGE_PER_SIZE = 8;

  static List<InputAction> findP2PSessionActions() {
    List<InputAction> actions = <InputAction>[];

    actions.add(PickImageFromAblumAction());

    // actions.add(PickImageFromAblumAction());
    // actions.add(PickImageFromAblumAction());
    // actions.add(PickImageFromAblumAction());
    // actions.add(PickImageFromAblumAction());
    // actions.add(PickImageFromAblumAction());
    // actions.add(PickImageFromAblumAction());
    // actions.add(PickImageFromAblumAction());
    // actions.add(PickImageFromAblumAction());
    // actions.add(PickImageFromAblumAction());
    // actions.add(PickImageFromAblumAction());

    return actions;
  }
}

///
/// 从相册选择图片
///
class PickImageFromAblumAction extends InputAction {
  PickImageFromAblumAction()
      : super(InputActionHelper.PICK_IMAGE_ABLUM, "相册", "ic_photo.png");

  @override
  void onClickAction(BuildContext context , InputPanelState inputPanel) async {
    LogUtil.log("click $name");
    FilePickerResult? pickerResult = await FilePicker.platform.pickFiles(type: FileType.image);
    if(pickerResult != null){
      LogUtil.log("用户选择文件 ${pickerResult.files.single.path}");
      String? path = pickerResult.files.single.path;
      
      if(path == null || path.isEmpty){
        return;
      }
      
      _onSelectedImage(context , path ,inputPanel);
    }else{
      LogUtil.log("用户选择取消");
    }
  }

  //选择图片后预览
  void _onSelectedImage(BuildContext context ,String imagePath , InputPanelState inputPanel) async{
    var path = await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => PreviewSendImage(imagePath))
    );

    if(path == null){
      return;
    }

    LogUtil.log("发送图片文件 $path");
    inputPanel.sendImageIMMessage(path);
  }
}
