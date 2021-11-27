import 'package:date_format/date_format.dart';

class TimerUtils {
  static String getMessageFormatTime(int timestamp) {
    int lasttimestamp = DateTime.now().millisecondsSinceEpoch;
    DateTime time = DateTime.fromMillisecondsSinceEpoch(timestamp);
    int diff = lasttimestamp - timestamp;
    int oneDay = 24 * 60 * 60 * 1000;
    if (diff < oneDay) {
      return formatDate(time, ["HH", ":", "nn"]);
    } else if (diff > oneDay) {
      return "昨天 " + formatDate(time, ["hh", ":", "mm"]);
    } else {
      return formatDate(
          time, ["yyyy", "年", "mm", "月", "dd", "日 ", "hh", ":", "MM"]);
    }
  }

  int getCurrentTimeStamp() {
    return DateTime.now().millisecondsSinceEpoch;
  }
}
