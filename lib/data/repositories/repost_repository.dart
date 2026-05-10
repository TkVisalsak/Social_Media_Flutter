import 'package:dio/dio.dart';

import '../models/repost_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/repost_provider.dart';
import 'repo_helpers.dart';

abstract class RepostRepository {
  Future<ApiResponse<RepostModel>> repost({
    required String contentId,
    required RepostContentType contentType,
    String? caption,
    String visibility = 'public',
  });
  Future<ApiResponse<void>> deleteRepost(String repostId);
  Future<ApiResponse<List<RepostModel>>> getUserReposts(String userId);
}

class RepostRepositoryImpl implements RepostRepository {
  final RepostProvider _provider;
  const RepostRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<RepostModel>> repost({
    required String contentId,
    required RepostContentType contentType,
    String? caption,
    String visibility = 'public',
  }) async {
    try {
      final res = contentType == RepostContentType.short
          ? await _provider.repostShort(
              contentId: contentId, caption: caption, visibility: visibility)
          : await _provider.repostFeed(
              contentId: contentId, caption: caption, visibility: visibility);

      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['repost'] ?? body['data'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid repost response');
      }
      raw['contentType'] = raw['contentType'] ?? contentType.name;
      return ApiResponse.success(RepostModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to repost'));
    } catch (e) {
      return ApiResponse.failure('Repost failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> deleteRepost(String repostId) async {
    try {
      await _provider.deleteRepost(repostId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to delete repost'));
    } catch (e) {
      return ApiResponse.failure('Delete repost failed: $e');
    }
  }

  @override
  Future<ApiResponse<List<RepostModel>>> getUserReposts(String userId) async {
    try {
      final res = await _provider.userReposts(userId);
      final list =
          RepoHelpers.extractList(res.data, keys: ['reposts', 'data']);
      final reposts = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(RepostModel.fromJson)
          .toList();
      return ApiResponse.success(reposts);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load reposts'));
    } catch (e) {
      return ApiResponse.failure('Reposts parse error: $e');
    }
  }
}
