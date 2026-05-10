import 'package:dio/dio.dart';
import '../network/exceptions/app_exception.dart';

/// Shared helpers used by all repositories.
class RepoHelpers {
  static Map<String, dynamic> normalizeBody(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return const {};
  }

  static List<dynamic> extractList(dynamic data, {List<String>? keys}) {
    if (data is List) return data;
    if (data is! Map<String, dynamic>) return const [];
    final candidates = [
      ...?keys,
      'data',
      'items',
      'results',
      'rows',
      'list',
    ];
    for (final k in candidates) {
      final v = data[k];
      if (v is List) return v;
    }
    for (final value in data.values) {
      if (value is List) return value;
    }
    return const [];
  }

  static Map<String, dynamic>? asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  static String dioErrorMessage(DioException e, {required String fallback}) {
    final wrapped = e.error;
    if (wrapped is AppException) return wrapped.message;

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final msg = responseData['message'] ??
          responseData['error'] ??
          responseData['detail'];
      if (msg is String && msg.trim().isNotEmpty) return msg;
    }
    final m = e.message;
    if (m != null && m.trim().isNotEmpty) return m;
    return fallback;
  }
}
