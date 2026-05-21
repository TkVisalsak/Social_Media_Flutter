import 'package:dio/dio.dart';

import '../models/comment_model.dart';
import '../models/short_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/short_provider.dart';
import 'repo_helpers.dart';

abstract class ShortRepository {
  Future<ApiResponse<List<ShortModel>>> getAllShorts();
  Future<ApiResponse<List<ShortModel>>> getFollowingShorts();
  Future<ApiResponse<List<ShortModel>>> getByUser(String userId);
  Future<ApiResponse<ShortModel>>       getById(String id);
  Future<ApiResponse<List<ShortModel>>> getLikedByUser(String userId);
  Future<ApiResponse<ShortModel>> uploadShort({
    required String filePath,
    String? caption,
    int? duration,
    void Function(double)? onProgress,
  });
  Future<ApiResponse<void>> recordView(String shortId);
  Future<ApiResponse<void>> toggleLike(String shortId);
  Future<ApiResponse<void>> incrementShare(String shortId);
  Future<ApiResponse<bool>> getLikeStatus(String shortId);

  Future<ApiResponse<List<CommentModel>>> getComments(String shortId);
  Future<ApiResponse<CommentModel>> addComment(String shortId,
      {required String text});
  Future<ApiResponse<CommentModel>> reply(String commentId,
      {required String text});
  Future<ApiResponse<void>> deleteComment(String commentId);
  Future<ApiResponse<void>> deleteShort(String id);
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
  @override
  Future<ApiResponse<List<ShortModel>>> getFollowingShorts() async {
    try {
      final res = await _provider.getFollowingShorts();
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
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load following shorts'));
    } catch (e) {
      return ApiResponse.failure('Following shorts error: $e');
    }
  }

  @override
  Future<ApiResponse<List<ShortModel>>> getByUser(String userId) async {
    try {
      final res = await _provider.getByUser(userId);
      final list = RepoHelpers.extractList(res.data, keys: ['videos', 'shorts', 'data']);
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
  Future<ApiResponse<ShortModel>> getById(String id) async {
    try {
      final res = await _provider.getById(id);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw  = RepoHelpers.asMap(body['video'] ?? body);
      if (raw == null) return ApiResponse.failure('Short not found');
      return ApiResponse.success(ShortModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load short'));
    } catch (e) {
      return ApiResponse.failure('Short parse error: $e');
    }
  }

  @override
  Future<ApiResponse<List<ShortModel>>> getLikedByUser(String userId) async {
    try {
      final res  = await _provider.getLikedByUser(userId);
      final list = RepoHelpers.extractList(res.data, keys: ['videos', 'shorts', 'data']);
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
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load liked shorts'));
    } catch (e) {
      return ApiResponse.failure('Liked shorts error: $e');
    }
  }

  @override
  Future<ApiResponse<ShortModel>> uploadShort({
    required String filePath,
    String? caption,
    int? duration,
    void Function(double)? onProgress,
  }) async {
    try {
      final res = await _provider.upload(
        filePath: filePath,
        caption: caption,
        duration: duration,
        onSendProgress: onProgress == null
            ? null
            : (sent, total) { if (total > 0) onProgress(sent / total); },
      );
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
  Future<ApiResponse<void>> incrementShare(String shortId) async {
    try {
      await _provider.incrementShare(shortId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to share short'));
    } catch (e) {
      return ApiResponse.failure('Share failed: $e');
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

  @override
  Future<ApiResponse<void>> deleteShort(String id) async {
    try {
      await _provider.deleteShort(id);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to delete short'));
    } catch (e) {
      return ApiResponse.failure('Delete short failed: $e');
    }
  }
}
