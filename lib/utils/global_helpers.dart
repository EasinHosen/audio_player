import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

final globalLogger = Logger();

final storage = GetStorage();

setLocalData(String key, dynamic value) {
  storage.write(key, value);
}

dynamic getLocalData(String key) {
  return storage.read(key);
}

loggerDebug(dynamic value, [String? message]) {
  return globalLogger.d(message, error: value);
}
