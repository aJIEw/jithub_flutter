import 'package:logger/logger.dart';

var logger = Logger(
  printer: PrefixPrinter(PrettyPrinter(
    // number of method calls to be displayed
    methodCount: 1,
    // number of method calls if stacktrace is provided
    errorMethodCount: 8,
    // width of the output
    lineLength: 120,
    // Colorful log messages
    colors: true,
    // Print an emoji for each log message
    printEmojis: true,
    // Should each log print contain a timestamp
    printTime: true,
  )),
);
