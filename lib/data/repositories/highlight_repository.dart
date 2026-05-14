import 'package:dio/dio.dart';
import '../models/highlight_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/highlight_provider.dart';
import 'repo_helpers.dart';

abstract class HighlightRepository {
  Future<ApiResponse<List<HighlightModel>>> getMyHighlights();
  Future<ApiResponse<HighlightModel>> create(String title, List<String> storyIds, {String? coverUrl});
  Future<ApiResponse<void>> delete(String id);
}

class HighlightRepositoryImpl implements HighlightRepository {
  final HighlightProvider _provider;
  const HighlightRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<List<HighlightModel>>> getMyHighlights() async {
    try {
      final res = await _provider.getMyHighlights();
      final list = RepoHelpers.extractList(res.data, keys: ['highlights', 'data']);
      return ApiResponse.success(list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(HighlightModel.fromJson)
          .toList());
    } on AppException catch (e) { return ApiResponse.failure(e.message); }
    on DioException catch (e) { return ApiResponse.failure(RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load highlights')); }
    catch (e) { return ApiResponse.failure('$e'); }
  }

  @override
  Future<ApiResponse<HighlightModel>> create(String title, List<String> storyIds, {String? coverUrl}) async {
    try {
      final res = await _provider.create(title, storyIds, coverUrl: coverUrl);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['highlight'] ?? body;
      if (raw is! Map<String, dynamic>) return ApiResponse.failure('Invalid response');
      return ApiResponse.success(HighlightModel.fromJson(raw));
    } on AppException catch (e) { return ApiResponse.failure(e.message); }
    on DioException catch (e) { return ApiResponse.failure(RepoHelpers.dioErrorMessage(e, fallback: 'Failed to create highlight')); }
    catch (e) { return ApiResponse.failure('$e'); }
  }

  @override
  Future<ApiResponse<void>> delete(String id) async {
    try {
      await _provider.delete(id);
      return const ApiResponse.success(null);
    } on AppException catch (e) { return ApiResponse.failure(e.message); }
    on DioException catch (e) { return ApiResponse.failure(RepoHelpers.dioErrorMessage(e, fallback: 'Failed to delete')); }
    catch (e) { return ApiResponse.failure('$e'); }
  }
}
