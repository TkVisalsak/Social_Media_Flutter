import 'package:dio/dio.dart';

import '../models/save_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/save_provider.dart';
import 'repo_helpers.dart';

abstract class SaveRepository {
  Future<ApiResponse<SaveModel>> save({
    required String contentId,
    required SaveContentType contentType,
  });
  Future<ApiResponse<void>> unsave(String contentId);
  Future<ApiResponse<bool>> isSaved(String contentId, {String? contentType});
  Future<ApiResponse<List<SaveModel>>> getSavedByUser(String userId);
}

class SaveRepositoryImpl implements SaveRepository {
  final SaveProvider _provider;
  const SaveRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<SaveModel>> save({
    required String contentId,
    required SaveContentType contentType,
  }) async {
    try {
      final res = await _provider.save(
        contentId: contentId,
        contentType: contentType.name,
      );
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['save'] ?? body['data'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid save response');
      }
      return ApiResponse.success(SaveModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to save'));
    } catch (e) {
      return ApiResponse.failure('Save failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> unsave(String contentId) async {
    try {
      await _provider.unsave(contentId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to unsave'));
    } catch (e) {
      return ApiResponse.failure('Unsave failed: $e');
    }
  }

  @override
  Future<ApiResponse<bool>> isSaved(String contentId, {String? contentType}) async {
    try {
      final res = await _provider.isSaved(contentId, contentType: contentType);
      final body = RepoHelpers.normalizeBody(res.data);
      return ApiResponse.success(body['saved'] == true);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to check save status'));
    } catch (e) {
      return ApiResponse.failure('Save check failed: $e');
    }
  }

  @override
  Future<ApiResponse<List<SaveModel>>> getSavedByUser(String userId) async {
    try {
      final res = await _provider.savedByUser(userId);
      final list =
          RepoHelpers.extractList(res.data, keys: ['saves', 'saved', 'data']);
      final saves = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(SaveModel.fromJson)
          .toList();
      return ApiResponse.success(saves);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to load saved items'));
    } catch (e) {
      return ApiResponse.failure('Saved items parse error: $e');
    }
  }
}
