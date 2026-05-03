import 'package:dio/dio.dart';

import '../models/comment_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/comments_provider.dart';

abstract class CommentsRepository {
  Future<ApiResponse<List<CommentModel>>> getComments(String postId);
  Future<ApiResponse<CommentModel>> addComment(
    String postId, {
    required String text,
    String? parentId,
  });
  Future<ApiResponse<void>> deleteComment(String commentId);
}

class CommentsRepositoryImpl implements CommentsRepository {
  final CommentsProvider _provider;
  const CommentsRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<List<CommentModel>>> getComments(String postId) async {
    try {
      final res = await _provider.getComments(postId);
      final list = _extractList(res.data);
      final comments = list
          .map((e) => _asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(CommentModel.fromJson)
          .toList();
      return ApiResponse.success(comments);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to load comments'));
    } catch (e) {
      return ApiResponse.failure('Comments parse error: $e');
    }
  }

  @override
  Future<ApiResponse<CommentModel>> addComment(
    String postId, {
    required String text,
    String? parentId,
  }) async {
    try {
      final res = await _provider.addComment(
        postId,
        text: text,
        parentId: parentId,
      );
      final body = _normalizeBody(res.data);
      final raw = body['comment'] ?? body['data'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid comment response from server');
      }
      return ApiResponse.success(CommentModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to add comment'));
    } catch (e) {
      return ApiResponse.failure('Add comment failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> deleteComment(String commentId) async {
    try {
      await _provider.deleteComment(commentId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to delete comment'));
    } catch (e) {
      return ApiResponse.failure('Delete comment failed: $e');
    }
  }

  Map<String, dynamic> _normalizeBody(dynamic data) {
    if (data is Map<String, dynamic>) {
      final nested = data['data'];
      if (nested is Map<String, dynamic>) return nested;
      return data;
    }
    return const {};
  }

  List<dynamic> _extractList(dynamic data) {
    if (data is List) return data;
    if (data is! Map<String, dynamic>) return const [];
    final direct = data['comments'] ?? data['data'] ?? data['items'] ?? data['rows'];
    if (direct is List) return direct;
    return const [];
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  String _dioErrorMessage(DioException e, {required String fallback}) {
    final wrappedError = e.error;
    if (wrappedError is AppException) return wrappedError.message;
    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] ?? responseData['error'] ?? responseData['detail'];
      if (message is String && message.trim().isNotEmpty) return message;
    }
    final msg = e.message;
    if (msg != null && msg.trim().isNotEmpty) return msg;
    return fallback;
  }
}

