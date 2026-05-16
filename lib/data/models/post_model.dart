import 'user_model.dart';
import '../../core/utils/json_util.dart';

class PostMedia {
  final String type; // 'image' | 'video'
  final String url;

  const PostMedia({required this.type, required this.url});

  factory PostMedia.fromJson(Map<String, dynamic> j) => PostMedia(
        type: j['type'] ?? 'image',
        url: j['url'] ?? '',
      );

  Map<String, dynamic> toJson() => {'type': type, 'url': url};
}

class PostModel {
  final String    id;
  final UserModel user;
  /// Post media URLs (images/videos). Empty when absent.
  final List<PostMedia> media;
  final String?   caption;
  final int       likesCount;
  final int       commentsCount;
  final int       sharesCount;
  final int       repostsCount;
  final bool      isLiked;
  final bool      isSaved;
  final String visibility; // ✅ added — backend has this
  final List<String> hashtags; // ✅ added — backend has this
  final String? location; // ✅ added — backend has this
  final bool isEdited; // ✅ added — backend has this
  final DateTime  createdAt;

  const PostModel({
    required this.id,
    required this.user,
    this.media = const [],
    this.caption,
    this.likesCount    = 0,
    this.commentsCount = 0,
    this.sharesCount   = 0,
    this.repostsCount  = 0,
    this.isLiked       = false,
    this.isSaved       = false,
    this.visibility    = 'public',
    this.hashtags      = const [],
    this.location       ,
    this.isEdited       = false,
    required this.createdAt,
  });
  List<String> get imageUrls => media
      .where((m) => m.type == 'image')
      .map((m) => m.url)
      .toList();

  List<String> get videoUrls => media
      .where((m) => m.type == 'video')
      .map((m) => m.url)
      .toList();

  String? get firstImageUrl => imageUrls.isNotEmpty ? imageUrls.first : null;

  // ── fromJson ──────────────────────────────────────
  factory PostModel.fromJson(Map<String, dynamic> j) {
    final userRaw = j['user'] ?? j['author'] ?? {};
    return PostModel(
      id: j['id'] ?? j['_id'] ?? '',
      user: UserModel.fromJson(userRaw is Map ? Map<String, dynamic>.from(userRaw) : {}),
      media: (j['media'] as List?)
              ?.map((e) => PostMedia.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      caption: JsonUtils.nullableString(j['caption']),
      likesCount: JsonUtils.toInt(j['likesCount']),
      commentsCount: JsonUtils.toInt(j['commentsCount']),
      sharesCount: JsonUtils.toInt(j['sharesCount']),
      repostsCount: JsonUtils.toInt(j['repostsCount']),
      isLiked: JsonUtils.toBool(j['isLiked']),
      isSaved: JsonUtils.toBool(j['isSaved']),
      visibility: j['visibility'] ?? 'public',
      hashtags: (j['hashtags'] as List?)?.map((e) => e.toString()).toList() ?? [],
      location: JsonUtils.nullableString(j['location']),
      isEdited: JsonUtils.toBool(j['isEdited']),
      createdAt: JsonUtils.toDateTime(j['createdAt']),
    );
  }
  // ── toJson ────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id':             id,
      'user':           user.toJson(),
      'media':          media.map((m) => m.toJson()).toList(),
      'caption':        caption,
      'likesCount':    likesCount,
      'commentsCount': commentsCount,
      'sharesCount':   sharesCount,
      'repostsCount':  repostsCount,
      'isLiked':       isLiked,
      'isSaved':       isSaved,
      'visibility':    visibility,
      'hashtags':      hashtags,
      'location':      location,
      'isEdited':      isEdited,
      'createdAt':     createdAt.toIso8601String(),
    };
  }

  // ── copyWith ──────────────────────────────────────
  PostModel copyWith({
    String?    id,
    UserModel? user,
    List<PostMedia>? media,
    String?    caption,
    int?       likesCount,
    int?       commentsCount,
    int?       sharesCount,
    int?       repostsCount,
    bool?      isLiked,
    bool?      isSaved,
    String?    visibility,
    List<String>? hashtags,
    String?    location,
    bool?      isEdited,
    DateTime?  createdAt,
  }) {
    return PostModel(
      id:            id            ?? this.id,
      user:          user          ?? this.user,
      media:         media         ?? this.media,
      caption:       caption       ?? this.caption,
      likesCount:    likesCount    ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      sharesCount:   sharesCount   ?? this.sharesCount,
      repostsCount:  repostsCount  ?? this.repostsCount,
      isLiked:       isLiked       ?? this.isLiked,
      isSaved:       isSaved       ?? this.isSaved,
      visibility:    visibility    ?? this.visibility,
      hashtags:      hashtags      ?? this.hashtags,
      location:      location      ?? this.location,
      isEdited:      isEdited      ?? this.isEdited,
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


}