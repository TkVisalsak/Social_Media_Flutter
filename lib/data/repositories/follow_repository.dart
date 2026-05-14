import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/follow_provider.dart';
import 'repo_helpers.dart';

abstract class FollowRepository {
  Future<ApiResponse<void>> follow(String userId);
  Future<ApiResponse<void>> unfollow(String userId);
  Future<ApiResponse<bool>> isFollowing(String userId);
  Future<ApiResponse<List<UserModel>>> getFollowers(String userId);
  Future<ApiResponse<List<UserModel>>> getFollowing(String userId);
  Future<ApiResponse<List<UserModel>>> getNotFollowingBack();
}

class FollowRepositoryImpl implements FollowRepository {
  final FollowProvider _provider;
  const FollowRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<void>> follow(String userId) async {
    try {
      await _provider.follow(userId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to follow user'));
    } catch (e) {
      return ApiResponse.failure('Follow failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> unfollow(String userId) async {
    try {
      await _provider.unfollow(userId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to unfollow user'));
    } catch (e) {
      return ApiResponse.failure('Unfollow failed: $e');
    }
  }

  @override
  Future<ApiResponse<bool>> isFollowing(String userId) async {
    try {
      final res = await _provider.isFollowing(userId);
      final body = RepoHelpers.normalizeBody(res.data);
      return ApiResponse.success(body['following'] == true);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to check follow status'));
    } catch (e) {
      return ApiResponse.failure('Follow check failed: $e');
    }
  }

  @override
  Future<ApiResponse<List<UserModel>>> getFollowers(String userId) async {
    try {
      final res = await _provider.followers(userId);
      final list =
          RepoHelpers.extractList(res.data, keys: ['followers', 'data']);
      final users = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map((j) {
            final inner = j['follower'];
            return inner is Map
                ? UserModel.fromJson(Map<String, dynamic>.from(inner))
                : UserModel.fromJson(j);
          })
          .toList();
      return ApiResponse.success(users);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load followers'));
    } catch (e) {
      return ApiResponse.failure('Followers parse error: $e');
    }
  }

  @override
  Future<ApiResponse<List<UserModel>>> getFollowing(String userId) async {
    try {
      final res = await _provider.following(userId);
      final list =
          RepoHelpers.extractList(res.data, keys: ['following', 'data']);
      final users = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map((j) {
            final inner = j['following'];
            return inner is Map
                ? UserModel.fromJson(Map<String, dynamic>.from(inner))
                : UserModel.fromJson(j);
          })
          .toList();
      return ApiResponse.success(users);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load following'));
    } catch (e) {
      return ApiResponse.failure('Following parse error: $e');
    }
  }

  @override
  Future<ApiResponse<List<UserModel>>> getNotFollowingBack() async {
    try {
      final res = await _provider.notFollowingBack();
      final list = RepoHelpers.extractList(res.data, keys: ['users']);
      final users = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(UserModel.fromJson)
          .toList();
      return ApiResponse.success(users);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load follow-back suggestions'));
    } catch (e) {
      return ApiResponse.failure('Not-following-back parse error: $e');
    }
  }
}
