import 'package:dio/dio.dart';

import '../models/hobby_model.dart';
import '../models/user_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/hobby_provider.dart';
import 'repo_helpers.dart';

class HobbySuggestion {
  const HobbySuggestion({required this.user, required this.matchCount});
  final UserModel user;
  final int matchCount;
}

abstract class HobbyRepository {
  Future<ApiResponse<List<HobbyModel>>> getAll();
  Future<ApiResponse<List<String>>> getMine();
  Future<ApiResponse<List<String>>> setMine(List<String> hobbies);
  Future<ApiResponse<List<HobbySuggestion>>> getSuggestions({int min = 3});
}

class HobbyRepositoryImpl implements HobbyRepository {
  final HobbyProvider _provider;
  const HobbyRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<List<HobbyModel>>> getAll() async {
    try {
      final res = await _provider.getAll();
      final list = RepoHelpers.extractList(res.data, keys: ['hobbies']);
      final hobbies = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(HobbyModel.fromJson)
          .toList();
      return ApiResponse.success(hobbies);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load hobbies'));
    } catch (e) {
      return ApiResponse.failure('Hobby parse error: $e');
    }
  }

  @override
  Future<ApiResponse<List<String>>> getMine() async {
    try {
      final res = await _provider.getMine();
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['hobbies'];
      final names = raw is List
          ? raw.whereType<String>().toList()
          : <String>[];
      return ApiResponse.success(names);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load hobbies'));
    } catch (e) {
      return ApiResponse.failure('Hobby parse error: $e');
    }
  }

  @override
  Future<ApiResponse<List<String>>> setMine(List<String> hobbies) async {
    try {
      final res = await _provider.setMine(hobbies);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['hobbies'];
      final saved = raw is List
          ? raw.whereType<String>().toList()
          : hobbies;
      return ApiResponse.success(saved);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to save hobbies'));
    } catch (e) {
      return ApiResponse.failure('Save error: $e');
    }
  }

  @override
  Future<ApiResponse<List<HobbySuggestion>>> getSuggestions({int min = 3}) async {
    try {
      final res = await _provider.suggestions(min: min);
      final list = RepoHelpers.extractList(res.data, keys: ['suggestions']);
      final users = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map((j) => HobbySuggestion(
                user: UserModel.fromJson(j),
                matchCount: (j['matchCount'] ?? 0) is int
                    ? j['matchCount'] as int
                    : int.tryParse('${j['matchCount']}') ?? 0,
              ))
          .toList();
      return ApiResponse.success(users);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to load suggestions'));
    } catch (e) {
      return ApiResponse.failure('Suggestions parse error: $e');
    }
  }
}
