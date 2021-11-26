enum MessageType {
  text,
  share,
  picture,
}

class ChatMessageModel {
  int uid = 0;
  String context = "";
  MessageType msgType = MessageType.text;
}
