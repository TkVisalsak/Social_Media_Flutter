import 'package:dio/dio.dart';

class HighlightProvider {
  const HighlightProvider(this._dio);
  final Dio _dio;

  Future<Response<dynamic>> getMyHighlights() => _dio.get('/highlights');
  Future<Response<dynamic>> create(String title, List<String> storyIds, {String? coverUrl}) =>
      _dio.post('/highlights', data: {'title': title, 'storyIds': storyIds, if (coverUrl != null) 'coverUrl': coverUrl});
  Future<Response<dynamic>> update(String id, {String? title, List<String>? storyIds}) =>
      _dio.put('/highlights/$id', data: {
        if (title != null) 'title': title,
        if (storyIds != null) 'storyIds': storyIds,
      });
  Future<Response<dynamic>> delete(String id) => _dio.delete('/highlights/$id');
}
