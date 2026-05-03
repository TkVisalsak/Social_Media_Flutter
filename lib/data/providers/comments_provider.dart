import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class CommentsProvider {
  const CommentsProvider(this._dio);

  final Dio _dio;

  Future<Response<dynamic>> getComments(String postId) {
  
    return _dio.get('${ApiEndpoints.comments}/$postId');
  }

  Future<Response<dynamic>> addComment(
    String postId, {
    required String text,
    String? parentId,
  }) {
  
    return _dio.post(
      '${ApiEndpoints.comments}/$postId',
      data: {
        'text': text,
        if (parentId != null && parentId.trim().isNotEmpty) 'parentId': parentId,
      },
    );
  }

  Future<Response<dynamic>> deleteComment(String commentId) {
  
    return _dio.delete('${ApiEndpoints.comments}/$commentId');
  }
}

