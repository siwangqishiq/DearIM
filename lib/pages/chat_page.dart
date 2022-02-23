import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:ffi';
import 'dart:math';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/trans.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/models/trans.dart';
import 'package:dearim/tcp/tcp_manager.dart';
import 'package:dearim/utils/timer_utils.dart';
import 'package:dearim/views/chat_view.dart';
import 'package:dearim/views/color_utils.dart';
import 'package:dearim/widget/emoji.dart';
import 'package:dearim/widget/more_action.dart';
import 'package:extended_text_field/extended_text_field.dart';
import 'package:flutter/material.dart';

///
/// P2P聊天页
///
class ChatPage extends StatefulWidget {
  final ContactModel model;

  final int sessionType = IMMessageSessionType.P2P;

  const ChatPage(this.model, {int sessionType = IMMessageSessionType.P2P,Key? key}) 
        : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  late List<ChatMessageModel> msgModels = [];
  final ScrollController _listViewController = ScrollController();
  String? receiveText = "";
  IMMessageIncomingCallback? _msgIncomingCallback;

  late InputPanelWidget inputPanelWidget;

  late ChatTitleWidget titleWidget;

  late GlobalKey inputKey;

  @override
  void initState() {
    super.initState();
    initMessageList();

    titleWidget = ChatTitleWidget(this);

    inputKey = GlobalKey();
    inputPanelWidget = InputPanelWidget(this , key : inputKey);
  }

  //查询历史消息
  List<ChatMessageModel> queryHistoryMessage() {
    List<ChatMessageModel> result = <ChatMessageModel>[];
    var imMsgList = IMClient.getInstance()
        .queryIMMessageList(IMMessageSessionType.P2P, widget.model.userId);
    for (IMMessage imMsg in imMsgList) {
      // result.add(ChatMessageModel.fromIMMessage(imMsg));
      result.insert(0, ChatMessageModel.fromIMMessage(imMsg));
    } //end for each
    
    return result;
  }

  void initMessageList() {
    msgModels.addAll(queryHistoryMessage()); //查询历史消息
    _msgIncomingCallback = (incomingIMMessageList) {
      IMMessage incomingMessage = incomingIMMessageList.last;

      if (incomingMessage.sessionId != widget.model.userId) {
        //不属于此会话的消息 不做处理
        return;
      }

      //
      IMClient.getInstance().clearUnreadCountBySession(incomingMessage.sessionType , incomingMessage.sessionId);

      setState(() {
        receiveText = incomingIMMessageList.last.content;
        LogUtil.log(receiveText!);
        ChatMessageModel incomingMsgModel =
          ChatMessageModel.fromIMMessage(incomingIMMessageList.last);
        // msgModels.add(incomingMsgModel);
        msgModels.insert(0, incomingMsgModel);
      });
    };

    TCPManager().registerMessageCommingCallbck(_msgIncomingCallback!);

    // scrollToBottom();

    //清零未读
    IMClient.getInstance().clearUnreadCountBySession(widget.sessionType , widget.model.userId);
  }

  @override
  Widget build(BuildContext context) {
    // SchedulerBinding.instance?.addPostFrameCallback((timeStamp) {
    //   LogUtil.log("一帧渲染完成后回调 $timeStamp");
    //   //scrollToBottom();
    // });

    LogUtil.log("ChatPageState build!!");

    // Future.delayed(const Duration(milliseconds: 1000),(){
    //   scrollToBottom();
    // });

    return Scaffold(
      appBar: AppBar(title: titleWidget),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: NotificationListener<ScrollUpdateNotification>(
                onNotification: (notification) {
                  // LogUtil.log("滑动 ${notification.scrollDelta}");
                  if(notification.scrollDelta!.abs() > 4.0){//向上滑动
                    (inputKey.currentState as InputPanelState).closeAllInputPanel();
                  }
                  return false;
                },
                child: Container(
                  color: ColorThemes.grayColor,
                  constraints:
                      BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                  child: ListView.builder(
                    reverse: true,
                    controller: _listViewController,
                    itemCount: msgModels.length,
                    itemBuilder: (BuildContext context, int index) {
                      ChatMessageModel msgModel = msgModels[index];
                      return ChatView(
                        msgModel,
                        preMsgModel: index + 1 < msgModels.length ? msgModels[index + 1] : null,
                        key: UniqueKey(),
                      );
                    },
                  ),
                ),
              )
            ),
            const SizedBox(
              height: 16,
            ),
            inputPanelWidget,
            const SizedBox(
              height: 16,
            ),
          ],
        ),
      ),
    );
  }

  void scrollToBottom() {
    // int microseconds = 1000;
    // Timer(Duration(microseconds: microseconds), () {
    //   _listViewController.jumpTo(_listViewController.position.maxScrollExtent);
    // });
    // _listViewController.jumpTo(_listViewController.position.maxScrollExtent);

    final double bottomOffset = _listViewController.position.maxScrollExtent;
    _listViewController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    if (_msgIncomingCallback != null) {
      TCPManager().unregistMessageCommingCallback(_msgIncomingCallback!);
    }
    super.dispose();
  }
}

///
/// 头部标题
///
class ChatTitleWidget extends StatefulWidget {
  final ChatPageState chatContext;

  const ChatTitleWidget(this.chatContext , {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatTitleState();
}

class ChatTitleState extends State<ChatTitleWidget> {
  late ContactModel contactModel;
  String? showTitle;
  bool isShowingInput = false;

  TransMessageIncomingCallback? _transMessageIncomingCallback;

  @override
  void initState() {
    super.initState();
    contactModel = widget.chatContext.widget.model;
    showTitle = contactModel.name;

    _transMessageIncomingCallback = (transMessage) {
      handleTransMessage(transMessage);
    };
    IMClient.getInstance()
        .registerTransMessageObserver(_transMessageIncomingCallback!, true);
  }

  void handleTransMessage(TransMessage transMessage) {
    if (transMessage.from != contactModel.userId) {
      return;
    }

    String? content = transMessage.content;
    if (content != null) {
      Map<String, dynamic> json = jsonDecode(content);
      int type = json[CustomTransTypes.KEY_TYPE];

      if (type == CustomTransTypes.TYPE_INPUTTING) {
        displayInputtingTips();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      showTitle ?? "",
      style: const TextStyle(color: Colors.white),
    );
  }

  void displayInputtingTips() {
    if (isShowingInput) {
      return;
    }

    setState(() {
      isShowingInput = true;
      showTitle = "正在输入中...";
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        showTitle = contactModel.name;
        isShowingInput = false;
      });
    });
  }

  @override
  void dispose() {
    if (_transMessageIncomingCallback != null) {
      IMClient.getInstance()
          .registerTransMessageObserver(_transMessageIncomingCallback!, false);
    }
    super.dispose();
  }
}

///
/// 输入面板
///
class InputPanelWidget extends StatefulWidget {
  final ChatPageState chatPageContext;

  const InputPanelWidget(this.chatPageContext, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InputPanelState();
  }
}

///
/// 输入框控件
///
class InputPanelState extends State<InputPanelWidget> {
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _textFieldController = TextEditingController();

  GlobalKey inputKey = GlobalKey();

  String text = "";
  bool _sendBtnVisible = false;
  bool _showEmojiGridPanel = false;
  List<String> emojiNames = EmojiManager.instance.listAllEmoji();

  int lastTransMsgSendTime = 0;

  bool _showMoreActionsVisible = false;

  //输入更多操作
  List<InputAction> inputActions = InputActionHelper.findP2PSessionActions();

  //记录光标位置
  TextSelection? inputTextSelection;

  @override
  void initState() {
    super.initState();

    // _textFieldController.addListener(() {
    //   final String text = _textFieldController.text;
    //   _textFieldController.value = _textFieldController.value.copyWith(
    //     text: text,
    //     selection:
    //         TextSelection(baseOffset: text.length, extentOffset: text.length),
    //     composing: TextRange.empty,
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [inputWidget(), emojiWidget(), moreActionsWidget()],
    );
  }

  int _inputActionsPageSize() {
    if (inputActions.length % InputActionHelper.PAGE_PER_SIZE == 0) {
      return inputActions.length ~/ InputActionHelper.PAGE_PER_SIZE;
    }
    return inputActions.length ~/ InputActionHelper.PAGE_PER_SIZE + 1;
  }

  Widget _moreActionPanelWidget(int index) {
    int offset = InputActionHelper.PAGE_PER_SIZE * index;
    int end = offset + InputActionHelper.PAGE_PER_SIZE >= inputActions.length
        ? inputActions.length
        : offset + InputActionHelper.PAGE_PER_SIZE;
    List<InputAction> subInputActions = inputActions.sublist(offset, end);

    // LogUtil.log("index : $index  subInputActions : ${subInputActions.length}");
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final InputAction action = subInputActions[index];
        return InkWell(
          onTap: () => action.onClickAction(context, this),
          child: Center(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                      width: 60,
                      height: 60,
                      color: ColorThemes.grayBgColor,
                      child: Center(
                        child: SizedBox(
                          child: Image.asset(action.icon,
                              width: 32, height: 32, fit: BoxFit.fitWidth),
                        ),
                      ))),
              Text(action.name,
                  style: const TextStyle(fontSize: 14, color: Colors.grey))
            ],
          )),
        );
      },
      itemCount: subInputActions.length,
    );
  }

  //更多操作
  Widget moreActionsWidget() {
    return Visibility(
        visible: _showMoreActionsVisible,
        child: SizedBox(
            height: 260,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                const Divider(
                  color: ColorThemes.grayBgDiv,
                  height: 1,
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: PageView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: _inputActionsPageSize(),
                        itemBuilder: (BuildContext context, int index) {
                          return _moreActionPanelWidget(index);
                        }),
                  ),
                )
              ],
            )));
  }

  void _toggleMoreActionsPanel() {
    _showMoreActionsVisible = !_showMoreActionsVisible;

    if (_showMoreActionsVisible) {
      _showEmojiGridPanel = false;
      _inputFocusNode.unfocus(); //关闭键盘
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  //插入文本
  void insertText(String insert, TextEditingController controller) {
    String text = controller.text;
    TextSelection textSelection = inputTextSelection ?? controller.selection;
    LogUtil.log(
        "text: $text , start : ${textSelection.start} end: ${textSelection.end}");
    String newText;
    int startPos;
    if (textSelection.start == -1 && textSelection.end == -1) {
      newText = insert;
      startPos = 0;
    } else {
      newText =
          text.replaceRange(textSelection.start, textSelection.end, insert);
      startPos = textSelection.start;
    }

    final int length = insert.length;
    controller.text = newText;
    controller.selection = textSelection.copyWith(
      baseOffset: startPos + length,
      extentOffset: startPos + length,
    );

    // int cursorPos = controller.selection.base.offset;
    // var selection = controller.selection;

    // LogUtil.log(
    //     "start : ${selection.start}   ${selection.end}  ${selection.toString()} ${selection.extentOffset}");

    // // controller.text = (controller.text + insert);

    // controller.selection =
    //     TextSelection.collapsed(offset: controller.text.length);

    // String newText = controller.text
    //     .replaceRange(max(cursorPos, 0), max(cursorPos, 0), insert);
    // controller.value = controller.value.copyWith(
    //     text: newText,
    //     selection: TextSelection.collapsed(offset: newText.length));

    // onInputTextChange(controller.text);
    // cursorPos = controller.selection.base.offset;
    // LogUtil.log("After cursorPos : $cursorPos");

    // EmojiInputTextState inputTextState =
    //     inputKey.currentState as EmojiInputTextState;
    //LogUtil.log("input globay key $type");
    // inputTextState.onChange(controller.text);

    onInputTextChange(controller.text);
  }

  Widget emojiWidget() {
    return Visibility(
        visible: _showEmojiGridPanel,
        child: SizedBox(
          height: 260,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: _emojiGridWidget(),
          ),
        ));
  }

  Widget _emojiGridWidget() {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1,
      ),
      itemBuilder: (BuildContext context, int index) {
        final String emojiName = emojiNames[index];
        return InkWell(
          onTap: () => _onSelectEmoji(emojiName),
          child: Image.asset(EmojiManager.instance.emojiAssetPath(emojiName)),
        );
      },
      itemCount: emojiNames.length,
    );
  }

  //选中一个表情
  void _onSelectEmoji(String emojiName) {
    // LogUtil.log("emoji: $emojiName");
    // LogUtil.log(
    //     "${_textFieldController.selection.hashCode} text: $text , start : ${_textFieldController.selection.start} end: ${_textFieldController.selection.end}");
    insertText(emojiName, _textFieldController);
  }

  //打开 或 关闭 表情输入面板
  void _toggleInputGridPanel() {
    _showEmojiGridPanel = !_showEmojiGridPanel;

    if (_showEmojiGridPanel) {
      _showMoreActionsVisible = false;
      _inputFocusNode.unfocus(); //关闭键盘
      Future.delayed(const Duration(milliseconds: 200), () {
        setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  Widget inputWidget() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: ExtendedTextField(
              key: inputKey,
              onSubmitted: (content) {
                // LogUtil.log("on submit content : $content");
                // LogUtil.log("=================================");
                // LogUtil.log("on submit text : $text");
                // LogUtil.log("=================================");
                
                sendTextIMMsg(content.trim());
              },
              onTap: () {
                // LogUtil.log("input tap");
                _textFieldController.selection.copyWith();
                if (_showEmojiGridPanel || _showMoreActionsVisible) {
                  setState(() {
                    _showEmojiGridPanel = false;
                    _showMoreActionsVisible = false;
                  });
                }
                // _textFieldController.selection = TextSelection.collapsed(
                //     offset: _textFieldController.text.length);
              },
              specialTextSpanBuilder: CustomSpecialTextSpanBuilder(),
              showCursor: true,
              focusNode: _inputFocusNode,
              onChanged: (_text) => onInputTextChange(_text),
              controller: _textFieldController,
              maxLines: null,
              textInputAction: TextInputAction.search,
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.fromLTRB(10, 4, 10, 4),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ),
        GestureDetector(
          onTap: _toggleInputGridPanel,
          child: Container(
            width: 40,
            height: 40,
            child: const Icon(Icons.face_rounded, color: Colors.grey),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 2.0),
              borderRadius: const BorderRadius.all(Radius.circular(30)),
            ),
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              onTap: _toggleMoreActionsPanel,
              child: Container(
                width: 40,
                height: 40,
                child: const Icon(
                  Icons.add,
                  color: Colors.grey,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey, width: 2.0),
                  borderRadius: const BorderRadius.all(Radius.circular(30)),
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _sendBtnVisible ? 60 : 0,
              height: _sendBtnVisible ? 40 : 0,
              child: ElevatedButton(
                onPressed: () => sendTextIMMsg(text),
                child: const Text("发送", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
        const SizedBox(
          width: 8,
        ),
      ],
    );
  }

  void onInputTextChange(String _text) {
    text = _text.trim();
    // String text2 = _textFieldController.text;
    // TextSelection textSelection = _textFieldController.selection;
    // LogUtil.log(
    //     "${_textFieldController.selection.hashCode} text: $text2 , start : ${textSelection.start} end: ${textSelection.end}");
    //_textFieldController.text = text;

    inputTextSelection = _textFieldController.selection;

    // _textFieldController.value = _textFieldController.value.copyWith(
    //     text: text, selection: TextSelection.collapsed(offset: text.length));

    setState(() {
      _sendBtnVisible = text.isNotEmpty;
    });

    sendInputCustomTransMsg();
  }

  //发送透传消息  告知对方 正在输入中...
  void sendInputCustomTransMsg() {
    int curTime = TimerUtils.getCurrentTimeStamp();

    //距离上一次发送间隔小于10s 不再发送
    if (curTime - lastTransMsgSendTime < 10 * 1000) {
      return;
    }

    TransMessage? msg = TransMessageBuilder.create(
        widget.chatPageContext.widget.model.userId,
        CustomTransBuilder.build(CustomTransTypes.TYPE_INPUTTING, null),
        null);

    IMClient.getInstance().sendTransMessage(msg!);
    lastTransMsgSendTime = curTime;
  }

  //添加新IM消息到消息列表中
  void _addIMMessageToList(IMMessage msg) {
    var msgList = widget.chatPageContext.msgModels;
    // msgList.add(ChatMessageModel.fromIMMessage(msg));
    msgList.insert(0, ChatMessageModel.fromIMMessage(msg));

    widget.chatPageContext.setState(() {
    });
    widget.chatPageContext.scrollToBottom();

    // Future.delayed(const Duration(milliseconds: 300), () {
    // });

    //LogUtil.log("总消息数量: ${msgList.length}");
  }

  //发送文本消息
  void sendTextIMMsg(String content) async {
    content = content.trim();

    var model = widget.chatPageContext.widget.model;

    if (_textFieldController.text.isEmpty) {
      _textFieldController.clear();
      _inputFocusNode.requestFocus();
      return;
    }

    var msg = await TCPManager().sendMessage(content, model.userId);
    if (msg == null) {
      return;
    }

    setState(() {
      _sendBtnVisible = false;
      _textFieldController.clear();
      inputTextSelection = _textFieldController.selection;
      //_textFieldController.text = "";

      //表情输入框 或 更多面板已经打开了 不需要再弹键盘
      if(_showEmojiGridPanel || _showMoreActionsVisible){
        return;
      }

      //发送文本后保留焦点 以方便下次输入
      _inputFocusNode.requestFocus();
    });

    //refresh message list
    _addIMMessageToList(msg);
  }

  //发送图片消息
  void sendImageIMMessage(String path) async {
    ContactModel model = widget.chatPageContext.widget.model;
    IMMessage? imageMsg = await IMMessageBuilder.createImage(
        model.userId, IMMessageSessionType.P2P, path);
    if (imageMsg == null) {
      return;
    }

    _addIMMessageToList(imageMsg);

    //关闭更多操作面板
    setState(() {
      _showMoreActionsVisible = false;
    });

    //send image im message
    IMClient.getInstance().sendIMMessage(imageMsg,
        callback: (imMessage, result) {
      LogUtil.log("图片消息 发送成功! ${imMessage.url}");
      widget.chatPageContext.setState(() {});
    });
  }

  ///
  /// 关闭所有键盘 表情 输入
  ///
  void closeAllInputPanel(){
    // LogUtil.log("hello closeAllInputPanel");
    
    if(_showMoreActionsVisible || _showEmojiGridPanel || _inputFocusNode.hasFocus){
      setState(() {
        _showMoreActionsVisible = false;
        _showEmojiGridPanel = false;
        _inputFocusNode.unfocus();
      });
    }
  }
}//end class input_panel_state
