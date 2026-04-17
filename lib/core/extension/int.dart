import 'package:sprintf/sprintf.dart';

extension IntExtension on int {
  static const List<String> zhNum = [
    '',
    '一',
    '二',
    '三',
    '四',
    '五',
    '六',
    '七',
    '八',
    '九',
    '十',
  ];

  /// 将 100 以内的整数转换为中文数字
  String toChineseNumber() {
    if (this > 0) {
      if (this < 10) {
        return zhNum[this];
      } else if (this > 9 && this < 100) {
        final int tens = this ~/ 10;
        final int ones = this % 10;
        return '${tens > 1 ? zhNum[tens] : ''}十${zhNum[ones]}';
      } else {
        return '';
      }
    } else {
      return '';
    }
  }

  String millisecondsToTimeString() {
    final int totalSeconds = this ~/ 1000;
    final int seconds = totalSeconds % 60;
    final int minutes = ((totalSeconds / 60) % 60).toInt();
    final int hours = totalSeconds ~/ 3600;
    return hours > 0
        ? sprintf.call('%02i:%02i:%02i', [hours, minutes, seconds])
        : sprintf.call('%02d:%02d', [minutes, seconds]);
  }

  String secondsToChineseTimeString() {
    final int totalSeconds = this;
    final int seconds = totalSeconds % 60;
    final int minutes = ((totalSeconds / 60) % 60).toInt();
    final int hours = totalSeconds ~/ 3600;

    final String hour = hours == 0 ? '' : '$hours小时';
    final String min = minutes == 0 ? '' : '$minutes分钟';
    final String sec = seconds == 0 ? '' : '$seconds秒';

    return hour + min + sec;
  }

  String autoPluralize(String single, String plural) {
    return this == 1 ? single : (toString() + plural);
  }
}
