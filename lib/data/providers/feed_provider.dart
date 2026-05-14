import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class FeedProvider {
  const FeedProvider(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getPostById(String postId) =>
      _dio.get('${ApiEndpoints.feeds}/$postId');

  Future<Response<dynamic>> getFeed({int page = 1, int limit = 20}) {
    return _dio.get(
      ApiEndpoints.feed,
      queryParameters: {
        'page':  page,
        'limit': limit,
      },
    );
  }

  Future<Response<dynamic>> likePost(String postId) {
    // Backend: POST /likes/:postId (toggle/like)
    return _dio.post('${ApiEndpoints.likes}/$postId');
  }

  Future<Response<dynamic>> unlikePost(String postId) {
    // If your backend doesn't support unlike, keep this unused.
    return _dio.delete('${ApiEndpoints.likes}/$postId');
  }

  Future<Response<dynamic>> likesCount(String postId) {
    // Backend: GET /likes/:postId/count
    return _dio.get('${ApiEndpoints.likes}/$postId/count');
  }

  Future<Response<dynamic>> savePost(String postId) {
    return _dio.post('${ApiEndpoints.posts}/$postId/save');
  }

  Future<Response<dynamic>> unsavePost(String postId) {
    return _dio.delete('${ApiEndpoints.posts}/$postId/save');
  }

  Future<Response<dynamic>> getUserPosts(String userId, {int page = 1, int limit = 12}) =>
      _dio.get('${ApiEndpoints.feedsByUser}/$userId',
          queryParameters: {'page': page, 'limit': limit});

  Future<Response<dynamic>> getLikedPosts(String userId) =>
      _dio.get('${ApiEndpoints.feeds}/liked/$userId');

  Future<Response<dynamic>> sharePost(String postId) =>
      _dio.post('${ApiEndpoints.likes}/$postId/share');

  Future<Response<dynamic>> createPost({
    String? caption,
    String? filePath,
    String visibility = 'public',
    String? location,
  }) async {
    final form = FormData.fromMap({
      if (caption != null && caption.trim().isNotEmpty) 'caption': caption.trim(),
      'visibility': visibility,
      if (location != null && location.isNotEmpty) 'location': location,
      if (filePath != null) 'file': await MultipartFile.fromFile(filePath),
    });
    return _dio.post(ApiEndpoints.feeds, data: form);
  }
}