import 'package:dio/dio.dart';

import '../models/comment_model.dart';
import '../models/short_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/short_provider.dart';
import 'repo_helpers.dart';

abstract class ShortRepository {
  Future<ApiResponse<List<ShortModel>>> getAllShorts();
  Future<ApiResponse<ShortModel>> uploadShort({
    required String filePath,
    String? caption,
    int? duration,
  });
  Future<ApiResponse<void>> recordView(String shortId);
  Future<ApiResponse<void>> toggleLike(String shortId);
  Future<ApiResponse<bool>> getLikeStatus(String shortId);

  Future<ApiResponse<List<CommentModel>>> getComments(String shortId);
  Future<ApiResponse<CommentModel>> addComment(String shortId,
      {required String text});
  Future<ApiResponse<CommentModel>> reply(String commentId,
      {required String text});
  Future<ApiResponse<void>> deleteComment(String commentId);
}

class ShortRepositoryImpl implements ShortRepository {
  final ShortProvider _provider;
  const ShortRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<List<ShortModel>>> getAllShorts() async {
    try {
      final res = await _provider.getAll();
      final list =
          RepoHelpers.extractList(res.data, keys: ['videos', 'shorts', 'data']);
      final shorts = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(ShortModel.fromJson)
          .toList();
      return ApiResponse.success(shorts);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load shorts'));
    } catch (e) {
      return ApiResponse.failure('Shorts parse error: $e');
    }
  }

  @override
  Future<ApiResponse<ShortModel>> uploadShort({
    required String filePath,
    String? caption,
    int? duration,
  }) async {
    try {
      final res = await _provider.upload(
          filePath: filePath, caption: caption, duration: duration);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['video'] ?? body['short'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid upload response');
      }
      return ApiResponse.success(ShortModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to upload short'));
    } catch (e) {
      return ApiResponse.failure('Upload failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> recordView(String shortId) async {
    try {
      await _provider.recordView(shortId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to record view'));
    } catch (e) {
      return ApiResponse.failure('View record failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> toggleLike(String shortId) async {
    try {
      await _provider.toggleLike(shortId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to like short'));
    } catch (e) {
      return ApiResponse.failure('Like failed: $e');
    }
  }

  @override
  Future<ApiResponse<bool>> getLikeStatus(String shortId) async {
    try {
      final res = await _provider.likeStatus(shortId);
      final body = RepoHelpers.normalizeBody(res.data);
      return ApiResponse.success(body['liked'] == true);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to check like status'));
    } catch (e) {
      return ApiResponse.failure('Like status failed: $e');
    }
  }

  @override
  Future<ApiResponse<List<CommentModel>>> getComments(String shortId) async {
    try {
      final res = await _provider.getComments(shortId);
      final list =
          RepoHelpers.extractList(res.data, keys: ['comments', 'data']);
      final comments = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(CommentModel.fromJson)
          .toList();
      return ApiResponse.success(comments);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load comments'));
    } catch (e) {
      return ApiResponse.failure('Comments parse error: $e');
    }
  }

  @override
  Future<ApiResponse<CommentModel>> addComment(String shortId,
      {required String text}) async {
    try {
      final res = await _provider.addComment(shortId, text: text);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['comment'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid comment response');
      }
      return ApiResponse.success(CommentModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to add comment'));
    } catch (e) {
      return ApiResponse.failure('Add comment failed: $e');
    }
  }

  @override
  Future<ApiResponse<CommentModel>> reply(String commentId,
      {required String text}) async {
    try {
      final res = await _provider.reply(commentId, text: text);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['comment'] ?? body['reply'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid reply response');
      }
      return ApiResponse.success(CommentModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to reply'));
    } catch (e) {
      return ApiResponse.failure('Reply failed: $e');
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
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to delete comment'));
    } catch (e) {
      return ApiResponse.failure('Delete failed: $e');
    }
  }
}
