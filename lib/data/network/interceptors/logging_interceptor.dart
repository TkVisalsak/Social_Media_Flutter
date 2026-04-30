import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class LoggingInterceptor extends LogInterceptor {
  LoggingInterceptor()
    : super(
        request: kDebugMode,
        requestBody: kDebugMode,
        requestHeader: kDebugMode,
        responseBody: kDebugMode,
        responseHeader: false,
        error: kDebugMode,
        logPrint: (obj) => debugPrint(obj.toString()),
      );
}