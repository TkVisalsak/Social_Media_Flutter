import 'package:dio/dio.dart';

import '../models/message_model.dart';
import '../models/story_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/story_provider.dart';
import 'repo_helpers.dart';

abstract class StoryRepository {
  Future<ApiResponse<StoryModel>> create({
    required String filePath,
    String type = 'image',
    String visibility = 'public',
    void Function(double)? onProgress,
  });
  Future<ApiResponse<List<StoryModel>>> getFeed();
  Future<ApiResponse<List<StoryModel>>> getMyStories();
  Future<ApiResponse<void>> recordView(String storyId);
  Future<ApiResponse<void>> deleteStory(String storyId);
  Future<ApiResponse<ConversationModel>> replyToStory(String storyId, String text);
  Future<ApiResponse<List<StoryViewer>>> getViewers(String storyId);
}

class StoryRepositoryImpl implements StoryRepository {
  final StoryProvider _provider;
  const StoryRepositoryImpl(this._provider);

  @override
  @override
  Future<ApiResponse<StoryModel>> create({
    required String filePath,
    String type = 'image',
    String visibility = 'public',
    void Function(double)? onProgress,
  }) async {
    try {
      final res = await _provider.create(
        filePath: filePath,
        type: type,
        visibility: visibility,
        onSendProgress: onProgress == null
            ? null
            : (sent, total) { if (total > 0) onProgress(sent / total); },
      );
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['story'] ?? body['data'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid story response');
      }
      return ApiResponse.success(StoryModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to create story'));
    } catch (e) {
      return ApiResponse.failure('Story create failed: $e');
    }
  }

  @override
  Future<ApiResponse<List<StoryModel>>> getFeed() async {
    try {
      final res = await _provider.feed();
      return _parseList(res.data);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to load story feed'));
    } catch (e) {
      return ApiResponse.failure('Stories parse error: $e');
    }
  }

  @override
  Future<ApiResponse<List<StoryModel>>> getMyStories() async {
    try {
      final res = await _provider.mine();
      return _parseList(res.data);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to load your stories'));
    } catch (e) {
      return ApiResponse.failure('Stories parse error: $e');
    }
  }

  ApiResponse<List<StoryModel>> _parseList(dynamic data) {
    final list = RepoHelpers.extractList(data, keys: ['stories', 'data']);
    final stories = list
        .map((e) => RepoHelpers.asMap(e))
        .whereType<Map<String, dynamic>>()
        .map(StoryModel.fromJson)
        .toList();
    return ApiResponse.success(stories);
  }

  @override
  Future<ApiResponse<void>> recordView(String storyId) async {
    try {
      await _provider.recordView(storyId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to record view'));
    } catch (e) {
      return ApiResponse.failure('View failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> deleteStory(String storyId) async {
    try {
      await _provider.delete(storyId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to delete story'));
    } catch (e) {
      return ApiResponse.failure('Delete story failed: $e');
    }
  }

  @override
  Future<ApiResponse<ConversationModel>> replyToStory(String storyId, String text) async {
    try {
      final res  = await _provider.reply(storyId, text);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw  = body['conversation'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid reply response');
      }
      return ApiResponse.success(ConversationModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to send reply'));
    } catch (e) {
      return ApiResponse.failure('Reply failed: $e');
    }
  }

  @override
  Future<ApiResponse<List<StoryViewer>>> getViewers(String storyId) async {
    try {
      final res  = await _provider.getViewers(storyId);
      final body = RepoHelpers.normalizeBody(res.data);
      final list = (body['viewers'] as List? ?? []);
      final viewers = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(StoryViewer.fromJson)
          .toList();
      return ApiResponse.success(viewers);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load viewers'));
    } catch (e) {
      return ApiResponse.failure('$e');
    }
  }
}
