class User {
  int uid = 0;
  String name = "";
  String token = "";
  TCPParam tcpParam = TCPParam();

  void clear() {
    this.uid = 0;
    this.name = "";
    this.token = "";
    tcpParam.imPort = 0;
    tcpParam.imServer = "";
  }
}

class TCPParam {
  String imServer = "";
  int imPort = 0;
}
