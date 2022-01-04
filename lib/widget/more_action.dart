// ignore_for_file: constant_identifier_names

import 'package:dearim/core/log.dart';
import 'package:flutter/widgets.dart';

///
/// 输入框 更多操作
///
class InputAction {
  final String name;
  final String icon;
  late int id = -1;

  InputAction(this.id, this.name, this.icon);

  void onClickAction(BuildContext context) {
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
    actions.add(PickImageFromAblumAction());
    actions.add(PickImageFromAblumAction());
    actions.add(PickImageFromAblumAction());
    actions.add(PickImageFromAblumAction());
    actions.add(PickImageFromAblumAction());
    actions.add(PickImageFromAblumAction());
    actions.add(PickImageFromAblumAction());
    actions.add(PickImageFromAblumAction());
    actions.add(PickImageFromAblumAction());

    return actions;
  }
}

///
/// 从相册选择图片
///
class PickImageFromAblumAction extends InputAction {
  PickImageFromAblumAction()
      : super(InputActionHelper.PICK_IMAGE_ABLUM, "相册", "");

  @override
  void onClickAction(BuildContext context) {
    LogUtil.log("click $name");
  }
}
