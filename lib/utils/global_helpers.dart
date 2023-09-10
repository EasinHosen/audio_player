import 'package:logger/logger.dart';

final globalLogger = Logger();

loggerDebug(dynamic value, [String? message]) {
  return globalLogger.d(message, error: value);
}
