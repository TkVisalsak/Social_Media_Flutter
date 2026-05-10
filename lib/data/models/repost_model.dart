import 'user_model.dart';
import '../../core/utils/json_util.dart';

enum RepostContentType { feed, short }

class RepostModel {
  const RepostModel({
    required this.id,
    required this.user,
    required this.contentId,
    required this.contentType,
    this.caption,
    this.visibility = 'public',
    required this.createdAt,
  });

  final String id;
  final UserModel user;
  final String contentId;
  final RepostContentType contentType; // 'feed' | 'short'
  final String? caption;
  final String visibility; // 'public' | 'friends' | 'private'
  final DateTime createdAt;

  factory RepostModel.fromJson(Map<String, dynamic> j) {
    final typeStr = (j['contentType'] ?? '').toString();
    final contentType =
        typeStr == 'short' ? RepostContentType.short : RepostContentType.feed;

    final userRaw = j['userId'] ?? j['user'];
    final userJson = userRaw is Map
        ? Map<String, dynamic>.from(userRaw)
        : {'_id': userRaw?.toString() ?? ''};

    return RepostModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      user: UserModel.fromJson(userJson),
      contentId: (j['contentId'] ?? '').toString(),
      contentType: contentType,
      caption: JsonUtils.nullableString(j['caption']),
      visibility: (j['visibility'] ?? 'public').toString(),
      createdAt: JsonUtils.toDateTime(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'user': user.toJson(),
        'contentId': contentId,
        'contentType': contentType.name,
        'caption': caption,
        'visibility': visibility,
        'createdAt': createdAt.toIso8601String(),
      };
}
