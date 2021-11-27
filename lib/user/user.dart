// ignore_for_file: file_names

class User {
  int uid = 0;
  String name = "";
  String token = "";
  String avatar = "";
  TCPParam tcpParam = TCPParam();

  void clear() {
    uid = 0;
    name = "";
    token = "";
    avatar = "";
    tcpParam.imPort = 0;
    tcpParam.imServer = "";
  }
}

class TCPParam {
  String imServer = "";
  int imPort = 0;
}
