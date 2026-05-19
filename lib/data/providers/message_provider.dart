import 'package:dio/dio.dart';

import '../network/api_endpoint.dart';

class MessageProvider {
  const MessageProvider(this._dio);
  final Dio _dio;

  // ── Direct messages ────────────────────────
  Future<Response<dynamic>> getSidebarUsers() =>
      _dio.get('${ApiEndpoints.messages}/users');

  Future<Response<dynamic>> getMessages(String userId) =>
      _dio.get('${ApiEndpoints.messages}/$userId');

  Future<Response<dynamic>> sendMessage(
    String userId, {
    String? text,
    String? image,
  }) =>
      _dio.post(
        '${ApiEndpoints.messages}/send/$userId',
        data: {
          if (text != null) 'text': text,
          if (image != null) 'image': image,
        },
      );

  // ── Conversations ──────────────────────────
  Future<Response<dynamic>> getConversations() =>
      _dio.get(ApiEndpoints.conversations);

  Future<Response<dynamic>> getOrCreateDm(String userId) =>
      _dio.post('${ApiEndpoints.conversationDm}/$userId');

  Future<Response<dynamic>> createGroup({
    required String name,
    required List<String> memberIds,
    String? avatar,
  }) =>
      _dio.post(ApiEndpoints.conversationGroup, data: {
        'name': name,
        'memberIds': memberIds,
        if (avatar != null) 'avatar': avatar,
      });

  Future<Response<dynamic>> getConversationMessages(String conversationId) =>
      _dio.get('${ApiEndpoints.conversations}/$conversationId/messages');
}
