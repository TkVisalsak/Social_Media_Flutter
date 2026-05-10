import 'user_model.dart';
import '../../core/utils/json_util.dart';

class StoryMedia {
  const StoryMedia({required this.type, required this.url, this.publicId});

  final String type; // 'image' | 'video'
  final String url;
  final String? publicId;

  factory StoryMedia.fromJson(Map<String, dynamic> j) => StoryMedia(
        type: (j['type'] ?? 'image').toString(),
        url: (j['url'] ?? '').toString(),
        publicId: JsonUtils.nullableString(j['publicId']),
      );

  Map<String, dynamic> toJson() =>
      {'type': type, 'url': url, 'publicId': publicId};
}

class StoryViewer {
  const StoryViewer({required this.user, required this.viewedAt});

  final UserModel user;
  final DateTime viewedAt;

  factory StoryViewer.fromJson(Map<String, dynamic> j) {
    final userRaw = j['user'];
    final userJson = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : {'_id': userRaw?.toString() ?? ''};
    return StoryViewer(
      user: UserModel.fromJson(userJson),
      viewedAt: JsonUtils.toDateTime(j['viewedAt']),
    );
  }

  Map<String, dynamic> toJson() =>
      {'user': user.toJson(), 'viewedAt': viewedAt.toIso8601String()};
}

class StoryModel {
  const StoryModel({
    required this.id,
    required this.user,
    required this.mediaUrl,
    this.type = 'image',
    this.viewers = const [],
    this.visibility = 'public',
    this.expiresAt,
    required this.createdAt,
  });

  final String id;
  final UserModel user;
  final List<StoryMedia> mediaUrl;
  final String type; // 'image' | 'video'
  final List<StoryViewer> viewers;
  final String visibility; // 'public' | 'friends' | 'private' | 'followers'
  final DateTime? expiresAt;
  final DateTime createdAt;

  bool get isExpired =>
      expiresAt != null && DateTime.now().isAfter(expiresAt!);

  factory StoryModel.fromJson(Map<String, dynamic> j) {
    final userRaw = j['user'] ?? j['userId'];
    final userJson = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : {'_id': userRaw?.toString() ?? ''};

    return StoryModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      user: UserModel.fromJson(userJson),
      mediaUrl: (j['mediaUrl'] as List? ?? [])
          .map((e) => StoryMedia.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      type: (j['type'] ?? 'image').toString(),
      viewers: (j['viewers'] as List? ?? [])
          .map((e) => StoryViewer.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      visibility: (j['visibility'] ?? 'public').toString(),
      expiresAt: j['expiresAt'] != null
          ? DateTime.tryParse(j['expiresAt'].toString())
          : null,
      createdAt: JsonUtils.toDateTime(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'mediaUrl': mediaUrl.map((m) => m.toJson()).toList(),
        'type': type,
        'viewers': viewers.map((v) => v.toJson()).toList(),
        'visibility': visibility,
        'expiresAt': expiresAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is StoryModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
