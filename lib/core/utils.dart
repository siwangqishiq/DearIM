import 'dart:typed_data';

class Utils {
  static const double epsiod = 0.000001;

  static bool floatEqual(num d1, num d2) {
    return abs(d1 - d2) < epsiod;
  }

  static num abs(num v) {
    return v >= 0 ? v : -v;
  }

  //string to Uint8List
  static Uint8List convertStringToUint8List(String str) {
    final List<int> codeUnits = str.codeUnits;
    final Uint8List unit8List = Uint8List.fromList(codeUnits);
    return unit8List;
  }

  //Uint8List to string
  static String convertUint8ListToString(Uint8List uint8list) {
    return String.fromCharCodes(uint8list);
  }

  static String intToHex(int value){
    if(value >=0 && value <16){
      return "0" + value.toRadixString(16);
    }
    return value.toRadixString(16);
  }

  //检测list中是否包含重复元素
  static bool listContainObj(List<Object> list , Object obj){
    if(list.isEmpty){
      return false;
    }

    for(Object lObj in list){
      if(lObj == obj){
        return true;
      }
    }    
      
    return false;
  }
}
