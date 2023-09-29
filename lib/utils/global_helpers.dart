import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:logger/logger.dart';

final globalLogger = Logger();

final storage = GetStorage();

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

setLocalData(String key, dynamic value) {
  storage.write(key, value);
}

dynamic getLocalData(String key) {
  return storage.read(key);
}

loggerDebug(dynamic value, [String? message]) {
  return globalLogger.d(message, error: value);
}
