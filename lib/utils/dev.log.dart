import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

/// # Description
///
/// Creates a Developer log class to use in application debugging
abstract class Dev {
  /// Flag for result printing
  static bool _shouldPrintResult = true;

  /// Getter for Debug mode
  bool get shouldPrintResult => _shouldPrintResult;

  /// Setter for Debug mode
  set changePrintResultMode(bool value) => _shouldPrintResult = value;

  static final log = Logger(
    filter: DevelopmentFilter(),
    printer: PrefixPrinter(
      PrettyPrinter(
        methodCount: 0,
        // number of method calls to be displayed
        errorMethodCount: 8,
        // number of method calls if stacktrace is provided
        lineLength: 100,
        // width of the output
        colors: false,
        // Colorful log messages
        printEmojis: true,
        // Print an emoji for each log message
        printTime: false, // Should each log print contain a timestamp
      ),
    ),
    // Use the PrettyPrinter to format and print log
    output: null, // Use the default LogOutput (-> send everything to console)
  );

  static void info(dynamic message) {
    if (kDebugMode) {
      log.i(message);
    }
  }

  static void debug(dynamic message) {
    if (kDebugMode) {
      log.d(message);
    }
  }

  static void debugFunction({
    required String functionName,
    required String className,
    required bool start,
    required String fileName,
    String customMessage = '',
  }) {
    if (kDebugMode) {
      final StringBuffer buffer = StringBuffer();

      if (customMessage.isNotEmpty) {
        buffer.write('[ $customMessage ] ');
      } else {
        buffer.write(start ? 'Running ==> ' : 'End ==> ');
      }

      buffer.writeAll([functionName, className, fileName], ' ==> ');

      log.d(buffer);

      // log.d(
      //     '${customMessage.isNotEmpty ? customMessage : start ? 'Running' : 'End'} ==> $fileName ==> $functionName');
    }
  }

  static void warn(dynamic message) {
    log.w(message);
  }

  static void error(dynamic message, {Object? error, StackTrace? stackTrace}) {
    log.e(message, error: error, stackTrace: stackTrace);
  }

  static void printResult(dynamic result) {
    if (_shouldPrintResult) {
      log.i(result);
    }
  }
}
