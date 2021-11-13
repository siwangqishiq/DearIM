
class Utils{
  static const double epsiod = 0.000001;

  static bool floatEqual(num d1 , num d2){
    return abs(d1 - d2) < epsiod;
  }

  static num abs(num v){
    return v>=0 ?v:-v;
  }
}