import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:math';

import 'package:dearim/core/imcore.dart';
import 'package:dearim/core/immessage.dart';
import 'package:dearim/core/log.dart';
import 'package:dearim/core/protocol/trans.dart';
import 'package:dearim/models/chat_message_model.dart';
import 'package:dearim/models/contact_model.dart';
import 'package:dearim/models/trans.dart';
import 'package:dearim/tcp/tcp_manager.dart';
import 'package:dearim/views/chat_view.dart';
import 'package:dearim/widget/emoji.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

///
/// P2P聊天页
///
class ChatPage extends StatefulWidget {
  final ContactModel model;

  const ChatPage(this.model, {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage>{
  late List<ChatMessageModel> msgModels = [];
  final ScrollController _listViewController = ScrollController();
  String? receiveText = "";
  IMMessageIncomingCallback? _msgIncomingCallback;

  late InputPanelWidget inputPanelWidget;

  late ChatTitleWidget titleWidget;

  @override
  void initState() {
    super.initState();
    initMessageList();

    titleWidget = ChatTitleWidget(this);
    inputPanelWidget = InputPanelWidget(this);    
  }

    //查询历史消息
  List<ChatMessageModel> queryHistoryMessage() {
    List<ChatMessageModel> result = <ChatMessageModel>[];
    var imMsgList = IMClient.getInstance()
          .queryIMMessageList(IMMessageSessionType.P2P, widget.model.userId);
    for (IMMessage imMsg in imMsgList) {
      result.add(ChatMessageModel.fromIMMessage(imMsg));
    } //end for each
    return result;
  }

  void initMessageList(){
    msgModels.addAll(queryHistoryMessage()); //查询历史消息
    _msgIncomingCallback = (incomingIMMessageList) {
      IMMessage incomingMessage = incomingIMMessageList.last;

      if (incomingMessage.sessionId != widget.model.userId) {
        //不属于此会话的消息 不做处理
        return;
      }

      setState(() {
        receiveText = incomingIMMessageList.last.content;
        LogUtil.log(receiveText!);
        ChatMessageModel incomingMsgModel =
            ChatMessageModel.fromIMMessage(incomingIMMessageList.last);
        msgModels.add(incomingMsgModel);
      });
    };
    TCPManager().registerMessageCommingCallbck(_msgIncomingCallback!);

    // scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance?.addPostFrameCallback((timeStamp) { 
      // LogUtil.log("一帧渲染完成后回调 $timeStamp");
      scrollToBottom();
    });

    return Scaffold(
      appBar: AppBar(title: titleWidget),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                constraints:
                    BoxConstraints(maxWidth: MediaQuery.of(context).size.width),
                child: ListView.builder(
                  controller: _listViewController,
                  itemCount: msgModels.length,
                  itemBuilder: (BuildContext context, int index) {
                    ChatMessageModel msgModel = msgModels[index];
                    return ChatView(msgModel , preMsgModel: index - 1 >=0?msgModels[index - 1]:null,);
                  },
                ),
              ),
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
    //_listViewController.jumpTo(_listViewController.position.maxScrollExtent);

    final bottomOffset = _listViewController.position.maxScrollExtent;
    _listViewController.animateTo(
      bottomOffset,
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

class ChatTitleWidget extends StatefulWidget{
  final ChatPageState chatContext;

  const ChatTitleWidget(this.chatContext);

  @override
  State<StatefulWidget> createState() => ChatTitleState();
}

class ChatTitleState extends State<ChatTitleWidget>{
  late ContactModel contactModel;
  String? showTitle;
  bool isShowingInput = false;

  TransMessageIncomingCallback? _transMessageIncomingCallback;

  @override
  void initState() {
    super.initState();
    contactModel = widget.chatContext.widget.model;
    showTitle = contactModel.name;

    _transMessageIncomingCallback = (transMessage){
      handleTransMessage(transMessage);
    };
    IMClient.getInstance().registerTransMessageObserver(_transMessageIncomingCallback!, true);
  }

  void handleTransMessage(TransMessage transMessage){
    if(transMessage.from != contactModel.userId){
      return;
    }

    String? content = transMessage.content;
    if(content != null){
      Map<String , dynamic> json = jsonDecode(content);
      int type = json[CustomTransTypes.KEY_TYPE];
      
      if(type == CustomTransTypes.TYPE_INPUTTING){
        displayInputtingTips();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      showTitle??"",
      style: const TextStyle(color: Colors.white),
    );
  }

  void displayInputtingTips(){
    if(isShowingInput){
      return;
    }

    setState(() {
      isShowingInput = true;
      showTitle = "正在输入中...";
    });

    Future.delayed(const Duration(seconds: 3) , (){
      setState(() {
        showTitle = contactModel.name;
        isShowingInput = false;
      });
    });
  }

  @override
  void dispose() {
    if(_transMessageIncomingCallback != null){
      IMClient.getInstance().registerTransMessageObserver(_transMessageIncomingCallback!, false);
    }
    super.dispose();
  }
}

///
/// 输入面板
///
class InputPanelWidget extends StatefulWidget{
  final ChatPageState chatPageContext;

  const InputPanelWidget(this.chatPageContext , {Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return InputPanelState();
  }
}

class InputPanelState extends State<InputPanelWidget>{
  final FocusNode _inputFocusNode = FocusNode();
  final TextEditingController _textFieldController = RichTextEditingController();

  String text = "";
  bool _sendBtnVisible = false;
  bool _showEmojiGridPanel = false;
  List<String> emojiNames = EmojiManager.instance.listAllEmoji();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        inputWidget(),
        emojiWidget()
      ],
    );
  }

  //插入文本
  void insertText(String insert, TextEditingController controller) {
    int cursorPos = controller.selection.base.offset;
    LogUtil.log("cursorPos : $cursorPos");

    String newText = controller.text.replaceRange(max(cursorPos, 0), max(cursorPos, 0), insert);
    controller.value = controller.value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: newText.length)
    );

    onInputTextChange(controller.text);
    cursorPos = controller.selection.base.offset;

    LogUtil.log("After cursorPos : $cursorPos");
  }

  Widget emojiWidget(){
    return Visibility(
      visible: _showEmojiGridPanel,
      child: SizedBox(
        height: 300,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: _emojiGridWidget(),
        ),
      ) 
    );
  }

  Widget _emojiGridWidget(){
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
        mainAxisSpacing: 4.0,
        crossAxisSpacing: 4.0,
        childAspectRatio: 1,
      ), 
      itemBuilder: (BuildContext context, int index){
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
  void _onSelectEmoji(String emojiName){
    LogUtil.log("emoji: $emojiName");
    insertText("[$emojiName]" , _textFieldController);
  }

  //打开 或 关闭 表情输入面板
  void _toggleInputGridPanel(){
    _showEmojiGridPanel = !_showEmojiGridPanel;

    if(_showEmojiGridPanel){
      _inputFocusNode.unfocus();//关闭键盘
      Future.delayed(const Duration(milliseconds: 200) , (){
        setState(() {});
      });
    }else{
       setState(() {});
    }
  }

  Widget inputWidget(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 8,
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 0, 8, 0),
            child: TextField(
              onSubmitted: (text) {
                sendTextIMMsg(text);
              },
              onTap: (){
                // LogUtil.log("input tap");
                if(_showEmojiGridPanel){
                  setState(() {
                    _showEmojiGridPanel = false;
                  });
                }
                
                _textFieldController.selection = TextSelection.collapsed(offset: _textFieldController.text.length);
              },
              showCursor: true,
              textInputAction: TextInputAction.send,
              maxLines: null,
              controller: _textFieldController,
              focusNode: _inputFocusNode,
              onChanged: (_text) => onInputTextChange(_text),
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
            child:const Icon(Icons.face_rounded , color: Colors.grey),
            decoration:BoxDecoration(
              border: Border.all(color:  Colors.grey ,width: 2.0),
              borderRadius:const BorderRadius.all(Radius.circular(30)),
            ),
          ),
        ),
        const SizedBox(
          width: 4,
        ),
        Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              child:const Icon(Icons.add , color: Colors.grey,),
              decoration:BoxDecoration(
                border: Border.all(color:  Colors.grey ,width: 2.0),
                borderRadius:const BorderRadius.all(Radius.circular(30)),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              width: _sendBtnVisible? 60 :0,
              height:_sendBtnVisible? 40 :0,
              child: ElevatedButton(
                onPressed: () => sendTextIMMsg(text),
                child:const Text("发送" , style: TextStyle(color: Colors.white)),
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

  void onInputTextChange(String _text){
    text = _text;

    setState(() {
       _sendBtnVisible = text.isNotEmpty;
    });
    sendInputCustomTransMsg();
  }

  void sendInputCustomTransMsg(){
    TransMessage? msg = TransMessageBuilder.create(widget.chatPageContext.widget.model.userId, 
      CustomTransBuilder.build(CustomTransTypes.TYPE_INPUTTING, null), null);
    
    IMClient.getInstance().sendTransMessage(msg!);
  }

  //发送文本消息
  void sendTextIMMsg(String content){
    var model = widget.chatPageContext.widget.model;

    if (_textFieldController.text.isEmpty) {
      return;
    }
    
    var msg = TCPManager().sendMessage(text, model.userId);
    if (msg == null) {
      return;
    }

    setState(() {
      _sendBtnVisible = false;
      _textFieldController.text = "";
    });

    //refresh message list
    var msgList = widget.chatPageContext.msgModels;
    msgList.add(ChatMessageModel.fromIMMessage(msg));
    widget.chatPageContext.setState(() {
    });

    Future.delayed(const Duration(milliseconds: 500) , (){
       widget.chatPageContext.scrollToBottom();
    });
  }
}

