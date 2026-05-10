import 'package:dio/dio.dart';

import '../models/message_model.dart';
import '../models/user_model.dart';
import '../network/api_response.dart';
import '../network/exceptions/app_exception.dart';
import '../providers/message_provider.dart';
import 'repo_helpers.dart';

abstract class MessageRepository {
  Future<ApiResponse<List<UserModel>>> getSidebarUsers();
  Future<ApiResponse<List<MessageModel>>> getMessages(String userId);
  Future<ApiResponse<MessageModel>> sendMessage(
    String userId, {
    String? text,
    String? image,
  });

  Future<ApiResponse<List<ConversationModel>>> getConversations();
  Future<ApiResponse<ConversationModel>> getOrCreateDm(String userId);
  Future<ApiResponse<ConversationModel>> createGroup({
    required String name,
    required List<String> memberIds,
    String? avatar,
  });
  Future<ApiResponse<List<MessageModel>>> getConversationMessages(
      String conversationId);
}

class MessageRepositoryImpl implements MessageRepository {
  final MessageProvider _provider;
  const MessageRepositoryImpl(this._provider);

  @override
  Future<ApiResponse<List<UserModel>>> getSidebarUsers() async {
    try {
      final res = await _provider.getSidebarUsers();
      final list = RepoHelpers.extractList(res.data, keys: ['users', 'data']);
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
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load users'));
    } catch (e) {
      return ApiResponse.failure('Users parse error: $e');
    }
  }

  @override
  Future<ApiResponse<List<MessageModel>>> getMessages(String userId) async {
    try {
      final res = await _provider.getMessages(userId);
      return _parseMessages(res.data);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load messages'));
    } catch (e) {
      return ApiResponse.failure('Messages parse error: $e');
    }
  }

  @override
  Future<ApiResponse<MessageModel>> sendMessage(
    String userId, {
    String? text,
    String? image,
  }) async {
    try {
      final res =
          await _provider.sendMessage(userId, text: text, image: image);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['message'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid send response');
      }
      return ApiResponse.success(MessageModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to send message'));
    } catch (e) {
      return ApiResponse.failure('Send failed: $e');
    }
  }

  @override
  Future<ApiResponse<List<ConversationModel>>> getConversations() async {
    try {
      final res = await _provider.getConversations();
      final list =
          RepoHelpers.extractList(res.data, keys: ['conversations', 'data']);
      final conversations = list
          .map((e) => RepoHelpers.asMap(e))
          .whereType<Map<String, dynamic>>()
          .map(ConversationModel.fromJson)
          .toList();
      return ApiResponse.success(conversations);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(RepoHelpers.dioErrorMessage(e,
          fallback: 'Failed to load conversations'));
    } catch (e) {
      return ApiResponse.failure('Conversations parse error: $e');
    }
  }

  @override
  Future<ApiResponse<ConversationModel>> getOrCreateDm(String userId) async {
    try {
      final res = await _provider.getOrCreateDm(userId);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['conversation'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid conversation response');
      }
      return ApiResponse.success(ConversationModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to open DM'));
    } catch (e) {
      return ApiResponse.failure('DM failed: $e');
    }
  }

  @override
  Future<ApiResponse<ConversationModel>> createGroup({
    required String name,
    required List<String> memberIds,
    String? avatar,
  }) async {
    try {
      final res = await _provider.createGroup(
          name: name, memberIds: memberIds, avatar: avatar);
      final body = RepoHelpers.normalizeBody(res.data);
      final raw = body['conversation'] ?? body;
      if (raw is! Map<String, dynamic>) {
        return ApiResponse.failure('Invalid group response');
      }
      return ApiResponse.success(ConversationModel.fromJson(raw));
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to create group'));
    } catch (e) {
      return ApiResponse.failure('Group create failed: $e');
    }
  }

  @override
  Future<ApiResponse<List<MessageModel>>> getConversationMessages(
      String conversationId) async {
    try {
      final res = await _provider.getConversationMessages(conversationId);
      return _parseMessages(res.data);
    } on AppException catch (e) {
      return ApiResponse.failure(e.message);
    } on DioException catch (e) {
      return ApiResponse.failure(
          RepoHelpers.dioErrorMessage(e, fallback: 'Failed to load messages'));
    } catch (e) {
      return ApiResponse.failure('Conversation messages parse error: $e');
    }
  }

  ApiResponse<List<MessageModel>> _parseMessages(dynamic data) {
    final list = RepoHelpers.extractList(data, keys: ['messages', 'data']);
    final msgs = list
        .map((e) => RepoHelpers.asMap(e))
        .whereType<Map<String, dynamic>>()
        .map(MessageModel.fromJson)
        .toList();
    return ApiResponse.success(msgs);
  }
}
