import 'package:dio/dio.dart';

typedef RefreshTokenReader = Future<String?> Function();
typedef AccessTokenWriter = Future<void> Function(String token);

class RefreshInterceptor extends QueuedInterceptorsWrapper {
  final Dio _dio;
  final RefreshTokenReader? refreshTokenReader;
  final AccessTokenWriter? accessTokenWriter;

  RefreshInterceptor(
    this._dio, {
    this.refreshTokenReader,
    this.accessTokenWriter,
  });

  @override
  Future onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }
    final refreshToken = await refreshTokenReader?.call();
    if (refreshToken == null || refreshToken.isEmpty) {
      return handler.next(err);
    }

    try {
      final newToken = await _refreshToken(refreshToken);
      await accessTokenWriter?.call(newToken);
      // Retry the original request with the new token
      final opts = err.requestOptions;
      opts.headers['Authorization'] = 'Bearer $newToken';
      final res = await _dio.fetch(opts);
      handler.resolve(res);
    } catch (_) {
      handler.next(err);
    }
  }

  Future<String> _refreshToken(String refreshToken) async {
    final res = await _dio.post('/auth/refresh', data: {
      'refreshToken': refreshToken,
    });
    return res.data['accessToken'];
  }
}