import 'package:dio/dio.dart';

import '../models/notification_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/notification_provider.dart';
import 'repo_helpers.dart';

abstract class NotificationRepository {
  Future<ApiResponse<List<NotificationModel>>> getAll();
  Future<ApiResponse<void>> markRead(String notificationId);
  Future<ApiResponse<void>> markAllRead();
}

class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationProvider _provider;
  const NotificationRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<List<NotificationModel>>> getAll() async {
    try {
      final res = await _provider.getAll();
      final list = RepoHelpers.extractList(res.data,
          keys: ['notifications', 'data', 'items']);
      final items = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(NotificationModel.fromJson)
          .toList();
      return ApiResponse.success(items);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to load notifications'));
    } catch (e) {
      return ApiResponse.failure('Notifications parse error: $e');
    }
  }

  @override
  Future<ApiResponse<void>> markRead(String notificationId) async {
    try {
      await _provider.markRead(notificationId);
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to mark as read'));
    } catch (e) {
      return ApiResponse.failure('Mark read failed: $e');
    }
  }

  @override
  Future<ApiResponse<void>> markAllRead() async {
    try {
      await _provider.markAllRead();
      return const ApiResponse.success(null);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to mark all as read'));
    } catch (e) {
      return ApiResponse.failure('Mark all read failed: $e');
    }
  }
}
