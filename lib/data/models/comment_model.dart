import 'user_model.dart';

class CommentModel {
  final String id;
  final String postId;
  final UserModel user;
  final String text;
  final String? parentId;
  final DateTime createdAt;

  const CommentModel({
    required this.id,
    required this.postId,
    required this.user,
    required this.text,
    this.parentId,
    required this.createdAt,
  });

  factory CommentModel.fromJson(Map<String, dynamic> j) {
    final userRaw = j['user'] ??
        j['author'] ??
        j['owner'] ??
        j['userId'] ??
        j['user_id'];

    final Map<String, dynamic> userJson;
    if (userRaw is Map) {
      userJson = Map<String, dynamic>.from(userRaw);
    } else if (userRaw is String) {
      userJson = <String, dynamic>{'id': userRaw};
    } else {
      userJson = <String, dynamic>{};
    }

    return CommentModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      postId: (j['postId'] ?? j['post_id'] ?? j['post'] ?? '').toString(),
      user: UserModel.fromJson(userJson),
      text: (j['text'] ?? j['content'] ?? '').toString(),
      parentId: _nullableString(j['parentId'] ?? j['parent_id']),
      createdAt: _toDateTime(j['createdAt'] ?? j['created_at']),
    );
  }

  static DateTime _toDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  static String? _nullableString(dynamic value) {
    if (value == null) return null;
    final s = value.toString().trim();
    return s.isEmpty ? null : s;
  }
}

