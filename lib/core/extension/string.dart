import 'package:jithub_flutter/core/extension/int.dart';

extension StringExtension on String {
  String removeDecimalZeros() {
    return replaceAll(RegExp(r"([.]*0+)(?!.*\d)"), "");
  }

  String limitLength(int max) {
    if (length > max) {
      return substring(0, max);
    }
    return this;
  }

  int timeStringToTimestamp() {
    return DateTime.parse(this).millisecondsSinceEpoch;
  }

  int toHexValue() => int.parse(replaceAll('#', '0xff'));

  String getFriendlyTime() {
    final now = DateTime.now();
    final date = DateTime.parse(this);
    final diff = now.difference(date);
    if (diff.inDays > 365) {
      return (diff.inDays ~/ 365).autoPluralize('last year', ' years ago');
    } else if (diff.inDays > 30) {
      return (diff.inDays ~/ 30).autoPluralize('last month', ' months ago');
    } else if (diff.inDays > 0) {
      return (diff.inDays).autoPluralize('yesterday', ' days ago');
    } else if (diff.inHours > 0) {
      return '${(diff.inHours).autoPluralize('1 hour', ' hours')} ago';
    } else if (diff.inMinutes > 0) {
      return '${(diff.inMinutes).autoPluralize('1 minute', ' minutes')} ago';
    } else if (diff.inSeconds > 0) {
      return '${(diff.inSeconds).autoPluralize('1 second', ' seconds')} ago';
    }
    return 'just now';
  }
}
