import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class ShortProvider {
  const ShortProvider(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> getAll() => _dio.get(ApiEndpoints.shortsAll);

  Future<Response<dynamic>> upload({
    required String filePath,
    String? caption,
    int? duration,
  }) async {
    final form = FormData.fromMap({
      'video': await MultipartFile.fromFile(filePath),
      if (caption != null) 'caption': caption,
      if (duration != null) 'duration': duration,
    });
    return _dio.post(ApiEndpoints.shortsCreate, data: form);
  }

  Future<Response<dynamic>> recordView(String shortId) =>
      _dio.post('${ApiEndpoints.shortsView}/$shortId/viewshort');

  Future<Response<dynamic>> toggleLike(String shortId) =>
      _dio.post('${ApiEndpoints.shortLikes}/$shortId/likeshort');

  Future<Response<dynamic>> likeStatus(String shortId) =>
      _dio.get('${ApiEndpoints.shortLikes}/$shortId/shortlike-status');

  Future<Response<dynamic>> getComments(String shortId) =>
      _dio.get('${ApiEndpoints.shortComments}/$shortId');

  Future<Response<dynamic>> addComment(String shortId,
          {required String text}) =>
      _dio.post('${ApiEndpoints.shortComments}/$shortId',
          data: {'text': text});

  Future<Response<dynamic>> reply(String commentId,
          {required String text}) =>
      _dio.post('${ApiEndpoints.shortComments}/$commentId/reply',
          data: {'text': text});

  Future<Response<dynamic>> deleteComment(String commentId) =>
      _dio.delete('${ApiEndpoints.shortComments}/$commentId');

  Future<Response<dynamic>> incrementShare(String shortId) =>
      _dio.post('${ApiEndpoints.shortLikes}/$shortId/shareshort');

  Future<Response<dynamic>> getByUser(String userId) =>
      _dio.get('${ApiEndpoints.shortsByUser}/$userId');
}
