import 'user_model.dart';

class PostModel {
  final String    id;
  final UserModel user;
  /// Post media URLs (images/videos). Empty when absent.
  final List<String> media;
  final String    url;
  final String?   caption;
  final int       likesCount;
  final int       commentsCount;
  final int       sharesCount;
  final bool      isLiked;
  final bool      isSaved;
  final DateTime  createdAt;

  const PostModel({
    required this.id,
    required this.user,
    this.media = const <String>[],
    required this.url,
    this.caption,
    this.likesCount    = 0,
    this.commentsCount = 0,
    this.sharesCount   = 0,
    this.isLiked       = false,
    this.isSaved       = false,
    required this.createdAt,
  });

  // ── fromJson ──────────────────────────────────────
  factory PostModel.fromJson(Map<String, dynamic> j) {
    final userJsonRaw =
        j['user'] ?? j['author'] ?? j['owner'] ?? j['userId'] ?? j['user_id'];
    final Map<String, dynamic> userJson;
    if (userJsonRaw is Map) {
      userJson = Map<String, dynamic>.from(userJsonRaw);
    } else if (userJsonRaw is String) {
      userJson = <String, dynamic>{'id': userJsonRaw};
    } else {
      userJson = <String, dynamic>{};
    }

    // Some APIs place author fields at the post level
    userJson['username'] ??= j['username'] ?? j['userName'] ?? j['user_name'];
    userJson['name'] ??= j['name'] ?? j['full_name'] ?? j['displayName'];
    userJson['avatar'] ??= j['avatar'] ?? j['avatar_url'] ?? j['avatarUrl'];

    final mediaRaw = j['media'] as List<dynamic>?;
    final media = (mediaRaw ?? const <dynamic>[])
        .map((e) {
          if (e is String) return e;
          if (e is Map) {
            final m = Map<String, dynamic>.from(e);
            return (m['url'] ?? m['src'] ?? m['path'])?.toString() ?? '';
          }
          return e.toString();
        })
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList(growable: false);

    final imageRaw = media.isNotEmpty ? media.first : (j['url'] ?? '');
    final createdRaw = j['created_at'] ?? j['createdAt'];

    return PostModel(
      id:            (j['id'] ?? j['_id'] ?? '').toString(),
      user:          UserModel.fromJson(userJson),
      media:         media,
      url:           imageRaw.toString(),
      caption:       _nullableString(j['caption'] ?? j['content'] ?? j['description']),
      likesCount:    _toInt(j['likes_count'] ?? j['likesCount'] ?? j['likes']),
      commentsCount: _toInt(j['comments_count'] ?? j['commentsCount'] ?? j['comments']),
      sharesCount:   _toInt(j['shares_count'] ?? j['sharesCount'] ?? j['shares']),
      isLiked:       _toBool(j['is_liked'] ?? j['isLiked']),
      isSaved:       _toBool(j['is_saved'] ?? j['isSaved']),
      createdAt:     _toDateTime(createdRaw),
    );
  }

  // ── toJson ────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id':             id,
      'user':           user.toJson(),
      'media':          media,
      'image_url':      url,
      'caption':        caption,
      'likes_count':    likesCount,
      'comments_count': commentsCount,
      'shares_count':   sharesCount,
      'is_liked':       isLiked,
      'is_saved':       isSaved,
      'created_at':     createdAt.toIso8601String(),
    };
  }

  // ── copyWith ──────────────────────────────────────
  PostModel copyWith({
    String?    id,
    UserModel? user,
    List<String>? media,
    String?    imageUrl,
    String?    caption,
    int?       likesCount,
    int?       commentsCount,
    int?       sharesCount,
    bool?      isLiked,
    bool?      isSaved,
    DateTime?  createdAt,
  }) {
    return PostModel(
      id:            id            ?? this.id,
      user:          user          ?? this.user,
      media:         media         ?? this.media,
      url:           imageUrl      ?? url,
      caption:       caption       ?? this.caption,
      likesCount:    likesCount    ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount:   sharesCount   ?? this.sharesCount,
      isLiked:       isLiked       ?? this.isLiked,
      isSaved:       isSaved       ?? this.isSaved,
      createdAt:     createdAt     ?? this.createdAt,
    );
  }

  // ── Equality ──────────────────────────────────────
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PostModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() =>
      'PostModel(id: $id, user: ${user.username}, likes: $likesCount)';

  static int _toInt(dynamic value) {
    if (value is int) return value;
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static bool _toBool(dynamic value) {
    if (value is bool) return value;
    final v = value?.toString().toLowerCase();
    return v == 'true' || v == '1';
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