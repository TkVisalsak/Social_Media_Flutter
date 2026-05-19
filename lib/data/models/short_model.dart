import 'user_model.dart';
import '../../core/utils/json_util.dart';

class ShortModel {
  const ShortModel({
    required this.id,
    required this.user,
    required this.videoUrl,
    String? thumbnailUrl,
    this.caption,
    this.likeCount = 0,
    this.commentCount = 0,
    this.shareCount = 0,
    this.views = 0,
    this.duration = 0,
    this.score = 0,
    this.visibility = 'public',
    this.isDeleted = false,
    this.isLiked = false,
    this.isSaved = false,
    required this.createdAt,
  }) : _thumbnailUrl = thumbnailUrl;

  final String id;
  final UserModel user;
  final String videoUrl;
  final String? _thumbnailUrl;

  /// Thumbnail URL. Falls back to a Cloudinary first-frame derivation when the
  /// server hasn't stored one (e.g. shorts uploaded before the fix).
  String? get thumbnailUrl {
    if (_thumbnailUrl != null && _thumbnailUrl.isNotEmpty) return _thumbnailUrl;
    if (videoUrl.isEmpty || !videoUrl.contains('cloudinary.com')) return null;
    return videoUrl
        .replaceFirst('/video/upload/', '/video/upload/so_0/')
        .replaceFirstMapped(
          RegExp(r'\.(mp4|mov|avi|mkv|webm)$', caseSensitive: false),
          (_) => '.jpg',
        );
  }
  final String? caption;
  final int likeCount;
  final int commentCount;
  final int shareCount;
  final int views;
  final int duration;
  final double score;
  final String visibility; // 'public' | 'followers' | 'friends' | 'private'
  final bool isDeleted;
  final bool isLiked;
  final bool isSaved;
  final DateTime createdAt;

  factory ShortModel.fromJson(Map<String, dynamic> j) {
    return ShortModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      user: UserModel.fromJson(
        j['user'] is Map ? Map<String, dynamic>.from(j['user']) : {'_id': j['userId']?.toString() ?? ''},
      ),
      videoUrl: (j['videoUrl'] ?? j['video_url'] ?? '').toString(),
      thumbnailUrl: JsonUtils.nullableString(j['thumbnailUrl'] ?? j['thumbnail_url']),
      caption: JsonUtils.nullableString(j['caption']),
      likeCount: JsonUtils.toInt(j['likeCount'] ?? j['likesCount']),
      commentCount: JsonUtils.toInt(j['commentCount'] ?? j['commentsCount']),
      shareCount: JsonUtils.toInt(j['shareCount'] ?? j['sharesCount']),
      views: JsonUtils.toInt(j['views']),
      duration: JsonUtils.toInt(j['duration']),
      score: (j['score'] is num) ? (j['score'] as num).toDouble() : 0.0,
      visibility: (j['visibility'] ?? 'public').toString(),
      isDeleted: JsonUtils.toBool(j['isDeleted']),
      isLiked: JsonUtils.toBool(j['isLiked'] ?? j['liked']),
      isSaved: JsonUtils.toBool(j['isSaved'] ?? j['saved']),
      createdAt: JsonUtils.toDateTime(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'videoUrl': videoUrl,
        'thumbnailUrl': thumbnailUrl,
        'caption': caption,
        'likeCount': likeCount,
        'commentCount': commentCount,
        'shareCount': shareCount,
        'views': views,
        'duration': duration,
        'score': score,
        'visibility': visibility,
        'isDeleted': isDeleted,
        'isLiked': isLiked,
        'isSaved': isSaved,
        'createdAt': createdAt.toIso8601String(),
      };

  ShortModel copyWith({
    String? id,
    UserModel? user,
    String? videoUrl,
    String? thumbnailUrl,
    String? caption,
    int? likeCount,
    int? commentCount,
    int? shareCount,
    int? views,
    int? duration,
    double? score,
    String? visibility,
    bool? isDeleted,
    bool? isLiked,
    bool? isSaved,
    DateTime? createdAt,
  }) =>
      ShortModel(
        id: id ?? this.id,
        user: user ?? this.user,
        videoUrl: videoUrl ?? this.videoUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        caption: caption ?? this.caption,
        likeCount: likeCount ?? this.likeCount,
        commentCount: commentCount ?? this.commentCount,
        shareCount: shareCount ?? this.shareCount,
        views: views ?? this.views,
        duration: duration ?? this.duration,
        score: score ?? this.score,
        visibility: visibility ?? this.visibility,
        isDeleted: isDeleted ?? this.isDeleted,
        isLiked: isLiked ?? this.isLiked,
        isSaved: isSaved ?? this.isSaved,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is ShortModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
