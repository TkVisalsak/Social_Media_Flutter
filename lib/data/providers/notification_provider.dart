import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class NotificationProvider {
  const NotificationProvider(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> getAll() => _dio.get(ApiEndpoints.notifications);

  Future<Response<dynamic>> markRead(String notificationId) =>
      _dio.put('${ApiEndpoints.notifications}/$notificationId/read');

  Future<Response<dynamic>> markAllRead() =>
      _dio.put('${ApiEndpoints.notifications}/read-all');
}
