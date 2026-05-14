import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class StoryProvider {
  const StoryProvider(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> create({
    required String filePath,
    String type = 'image',
    String visibility = 'public',
  }) async {
    final form = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'type': type,
      'visibility': visibility,
    });
    return _dio.post(ApiEndpoints.stories, data: form);
  }

  Future<Response<dynamic>> feed() => _dio.get(ApiEndpoints.storyFeed);

  Future<Response<dynamic>> mine() => _dio.get(ApiEndpoints.storyMine);

  Future<Response<dynamic>> recordView(String storyId) =>
      _dio.post('${ApiEndpoints.storyView}/$storyId');

  Future<Response<dynamic>> delete(String storyId) =>
      _dio.delete('${ApiEndpoints.stories}/$storyId');

  Future<Response<dynamic>> reply(String storyId, String text) =>
      _dio.post('${ApiEndpoints.stories}/$storyId/reply', data: {'text': text});

  Future<Response<dynamic>> getViewers(String storyId) =>
      _dio.get('${ApiEndpoints.stories}/$storyId/viewers');
}
