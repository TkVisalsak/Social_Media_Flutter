import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class RepostProvider {
  const RepostProvider(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> repostFeed({
    required String contentId,
    String? caption,
    String visibility = 'public',
  }) =>
      _dio.post(ApiEndpoints.repostFeed, data: {
        'contentId': contentId,
        if (caption != null) 'caption': caption,
        'visibility': visibility,
      });

  Future<Response<dynamic>> repostShort({
    required String contentId,
    String? caption,
    String visibility = 'public',
  }) =>
      _dio.post(ApiEndpoints.repostShort, data: {
        'contentId': contentId,
        if (caption != null) 'caption': caption,
        'visibility': visibility,
      });

  Future<Response<dynamic>> deleteRepost(String repostId) =>
      _dio.delete('${ApiEndpoints.repost}/$repostId');

  Future<Response<dynamic>> userReposts(String userId) =>
      _dio.get('${ApiEndpoints.repostUser}/$userId');
}
