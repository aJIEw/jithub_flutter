import 'package:sprintf/sprintf.dart';

extension IntExtension on int {
  static const List<String> ZH_NUM = ["", "一", "二", "三", "四", "五", "六", "七", "八", "九", "十"];

  /// 将 100 以内的整数转换为中文数字
  String toChineseNumber() {
    if (this > 0) {
      if (this < 10) {
        return ZH_NUM[this];
      } else if (this > 9 && this < 100) {
        int tens = this ~/ 10;
        int ones = this % 10;
        return '${tens > 1 ? ZH_NUM[tens] : ''}十${ZH_NUM[ones]}';
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  String millisecondsToTimeString() {
    int totalSeconds = this ~/ 1000;
    int seconds = totalSeconds % 60;
    int minutes = ((totalSeconds / 60) % 60).toInt();
    int hours = totalSeconds ~/ 3600;
    return hours > 0
        ? sprintf.call("%02i:%02i:%02i", [hours, minutes, seconds])
        : sprintf.call("%02d:%02d", [minutes, seconds]);
  }

  String secondsToChineseTimeString() {
    int totalSeconds = this;
    int seconds = totalSeconds % 60;
    int minutes = ((totalSeconds / 60) % 60).toInt();
    int hours = totalSeconds ~/ 3600;

    String hour = hours == 0 ? '' : '$hours小时';
    String min = minutes == 0 ? '' : '$minutes分钟';
    String sec = seconds == 0 ? '' : '$seconds秒';

    return hour + min + sec;
  }
}
