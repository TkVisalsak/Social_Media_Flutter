import 'package:dio/dio.dart';

import '../models/user_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/user_provider.dart';
import 'repo_helpers.dart';

abstract class UserRepository {
  Future<ApiResponse<UserModel>> getById(String userId);
  Future<ApiResponse<UserModel>> me();
  Future<ApiResponse<void>> updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? dob,
    String? gender,
    String? bio,
  });
  Future<ApiResponse<UserModel>> updateProfilePic(String profilePicUrl);
  Future<ApiResponse<String?>> getEmail();
}

class UserRepositoryImpl implements UserRepository {
  final UserProvider _provider;
  const UserRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<UserModel>> getById(String userId) async {
    try {
      final res = await _provider.getById(userId);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['user'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid user response');
      }
      return ApiResponse.success(UserModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load user'));
    } catch (e) {
      return ApiResponse.failure('User parse error: $e');
    }
  }

  @override
  Future<ApiResponse<UserModel>> me() async {
    try {
      final res = await _provider.me();
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['user'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid user response');
      }
      return ApiResponse.success(UserModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load profile'));
    } catch (e) {
      return ApiResponse.failure('Me parse error: $e');
    }
  }

  @override
  Future<ApiResponse<void>> updatePersonalInfo({
    String? firstName,
    String? lastName,
    String? dob,
    String? gender,
    String? bio,
  }) async {
    try {
      await _provider.updatePersonalInfo(
        firstName: firstName,
        lastName: lastName,
        dob: dob,
        gender: gender,
        bio: bio,
      );
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to update profile'));
    } catch (e) {
      return ApiResponse.failure('Update failed: $e');
    }
  }

  @override
  Future<ApiResponse<UserModel>> updateProfilePic(String profilePicUrl) async {
    try {
      final res = await _provider.updateProfilePic(profilePicUrl);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['updatedUser'] ?? body['user'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid update response');
      }
      return ApiResponse.success(UserModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to update profile picture'));
    } catch (e) {
      return ApiResponse.failure('Profile pic update failed: $e');
    }
  }

  @override
  Future<ApiResponse<String?>> getEmail() async {
    try {
      final res = await _provider.getEmail();
      final body = RepoHelpers.normalizeBody(res.data);
      final email = body['email']?.toString();
      return ApiResponse.success(email);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load email'));
    } catch (e) {
      return ApiResponse.failure('Email parse error: $e');
    }
  }
}
