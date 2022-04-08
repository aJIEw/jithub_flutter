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
}
