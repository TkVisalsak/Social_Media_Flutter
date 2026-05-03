import 'package:dio/dio.dart';

import '../models/post_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/feed_provider.dart';
import '../providers/auth_provider.dart';

abstract class FeedRepository {
  Future<ApiResponse<List<PostModel>>> getFeed(int page);
  Future<ApiResponse<void>>            toggleLike(String postId, {required bool wasLiked});
  Future<ApiResponse<int>>             getLikesCount(String postId);
  Future<ApiResponse<void>>            savePost(String postId);
}

class FeedRepositoryImpl implements FeedRepository {
  final FeedProvider _provider;
  const FeedRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<List<PostModel>>> getFeed(int page) async {
    try {
      final res = await _provider.getFeed(page: page);
      final rawList = _extractFeedList(res.data);
      final posts = rawList
          .map((j) => _asMap(j))
          .whereType<Map<String, dynamic>>()
          .map((j) => PostModel.fromJson(j))
          .toList();
      return ApiResponse.success(posts);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to load feed'));
    } catch (e) {
      return ApiResponse.failure('Feed parse error: $e');
    }
  }

  @override
  Future<ApiResponse<void>> toggleLike(String postId, {required bool wasLiked}) async {
    try {
      // Backend spec: POST /likes/:postId (toggle/like). If you support DELETE, uncomment logic.
      await _provider.likePost(postId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to like post'));
    } catch (e) {
      return ApiResponse.failure('Like action failed: $e');
    }
  }

  @override
  Future<ApiResponse<int>> getLikesCount(String postId) async {
    try {
      final res = await _provider.likesCount(postId);
      final data = res.data;
      if (data is int) return ApiResponse.success(data);
      if (data is Map<String, dynamic>) {
        final v = data['count'] ?? data['likesCount'] ?? data['likes_count'];
        final parsed = int.tryParse(v?.toString() ?? '');
        if (parsed != null) return ApiResponse.success(parsed);
      }
      final parsed = int.tryParse(data?.toString() ?? '');
      return ApiResponse.success(parsed ?? 0);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to fetch likes count'));
    } catch (e) {
      return ApiResponse.failure('Likes count failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> savePost(String postId) async {
    try {
      await _provider.savePost(postId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(_dioErrorMessage(e, fallback: 'Failed to save post'));
    } catch (e) {
      return ApiResponse.failure('Save action failed: $e');
    }
  }

  List<dynamic> _extractFeedList(dynamic data) {
    if (data is List) return data;
    if (data is! Map<String, dynamic>) return const [];

    final direct = data['posts'] ??
        data['data'] ??
        data['items'] ??
        data['feed'] ??
        data['results'] ??
        data['rows'];
    if (direct is List) return direct;

    final recursive = _findFirstListInMap(data);
    return recursive ?? const [];
  }

  Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return null;
  }

  List<dynamic>? _findFirstListInMap(Map<String, dynamic> map) {
    for (final value in map.values) {
      if (value is List) return value;
      if (value is Map<String, dynamic>) {
        final nested = _findFirstListInMap(value);
        if (nested != null) return nested;
      }
    }
    return null;
  }

  String _dioErrorMessage(DioException e, {required String fallback}) {
    final wrappedError = e.error;
    if (wrappedError is AppException) {
      return wrappedError.message;
    }

    final responseData = e.response?.data;
    if (responseData is Map<String, dynamic>) {
      final message = responseData['message'] ?? responseData['error'] ?? responseData['detail'];
      if (message is String && message.trim().isNotEmpty) {
        return message;
      }
    }

    final msg = e.message;
    if (msg != null && msg.trim().isNotEmpty) {
      return msg;
    }
    return fallback;
  }
}