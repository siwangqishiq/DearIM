enum MessageType {
  text,
  share,
  picture,
}

class ChatMessageModel {
  int uid = 0;
  String context = "";
  int updateTime = 0;
  MessageType msgType = MessageType.text;
}
