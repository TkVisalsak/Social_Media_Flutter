import 'user_model.dart';
import '../../core/utils/json_util.dart';

/// Covers both feed comments (feedId) and short comments (shortId).
class CommentModel {
  const CommentModel({
    required this.id,
    required this.user,
    required this.text,
    this.feedId,
    this.shortId,
    this.parentId,
    this.replyCount = 0,
    this.likeCount = 0,
    this.isLiked = false,
    this.isEdited = false,
    required this.createdAt,
  });

  final String id;
  final UserModel user;
  final String text;
  final String? feedId;
  final String? shortId;
  final String? parentId;
  final int replyCount;
  final int likeCount;
  final bool isLiked;
  final bool isEdited;
  final DateTime createdAt;

  factory CommentModel.fromJson(Map<String, dynamic> j) {
    final userRaw = j['user'] ?? j['author'] ?? j['owner'] ?? j['userId'];
    final Map<String, dynamic> userJson = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : userRaw is String
            ? {'_id': userRaw}
            : {};

    return CommentModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      user: UserModel.fromJson(userJson),
      text: (j['text'] ?? j['content'] ?? '').toString(),
      feedId: JsonUtils.nullableString(j['feedId'] ?? j['feed_id']),
      shortId: JsonUtils.nullableString(j['shortId'] ?? j['short_id']),
      parentId: JsonUtils.nullableString(j['parentId'] ?? j['parent_id']),
      replyCount: JsonUtils.toInt(j['replyCount'] ?? j['commentCount']),
      likeCount: JsonUtils.toInt(j['likeCount']),
      isLiked: JsonUtils.toBool(j['isLiked'] ?? j['liked']),
      isEdited: JsonUtils.toBool(j['isEdited']),
      createdAt: JsonUtils.toDateTime(j['createdAt'] ?? j['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'text': text,
        'feedId': feedId,
        'shortId': shortId,
        'parentId': parentId,
        'replyCount': replyCount,
        'likeCount': likeCount,
        'isLiked': isLiked,
        'isEdited': isEdited,
        'createdAt': createdAt.toIso8601String(),
      };

  CommentModel copyWith({
    String? id,
    UserModel? user,
    String? text,
    String? feedId,
    String? shortId,
    String? parentId,
    int? replyCount,
    int? likeCount,
    bool? isLiked,
    bool? isEdited,
    DateTime? createdAt,
  }) =>
      CommentModel(
        id: id ?? this.id,
        user: user ?? this.user,
        text: text ?? this.text,
        feedId: feedId ?? this.feedId,
        shortId: shortId ?? this.shortId,
        parentId: parentId ?? this.parentId,
        replyCount: replyCount ?? this.replyCount,
        likeCount: likeCount ?? this.likeCount,
        isLiked: isLiked ?? this.isLiked,
        isEdited: isEdited ?? this.isEdited,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is CommentModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
