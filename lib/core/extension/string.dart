import 'package:jithub_flutter/core/extension/int.dart';

const String _githubAvatarHost = 'avatars.githubusercontent.com';

extension StringExtension on String {
  /// Returns this GitHub avatar URL requested at [size] pixels.
  ///
  /// Returns the original string when it is empty, [size] is not positive,
  /// the URL is not a GitHub avatar URL, the URL has no `s` parameter, or the
  /// URL cannot be parsed.
  String githubAvatarAtSize(int size) {
    if (size <= 0 || isEmpty) {
      return this;
    }

    final Uri? uri = Uri.tryParse(this);
    if (uri == null || uri.host != _githubAvatarHost) {
      return this;
    }

    try {
      final Map<String, String> queryParameters = uri.queryParameters;
      if (!queryParameters.containsKey('s')) {
        return this;
      }
      return uri
          .replace(
            queryParameters: <String, String>{...queryParameters, 's': '$size'},
          )
          .toString();
    } on FormatException {
      return this;
    }
  }

  String removeDecimalZeros() {
    return replaceAll(RegExp(r'([.]*0+)(?!.*\d)'), '');
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
