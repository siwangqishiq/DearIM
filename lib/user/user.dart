// ignore_for_file: file_names

class User {
  int uid = 0;
  String name = "";
  String token = "";
  TCPParam tcpParam = TCPParam();

  void clear() {
    uid = 0;
    name = "";
    token = "";
    tcpParam.imPort = 0;
    tcpParam.imServer = "";
  }
}

class TCPParam {
  String imServer = "";
  int imPort = 0;
}
