import '../../core/utils/json_util.dart';

enum SaveContentType { feed, short }

class SaveModel {
  const SaveModel({
    required this.id,
    required this.userId,
    required this.contentId,
    required this.contentType,
    required this.createdAt,
  });

  final String id;
  final String userId;
  final String contentId;
  final SaveContentType contentType; // 'feed' | 'short'
  final DateTime createdAt;

  factory SaveModel.fromJson(Map<String, dynamic> j) {
    final typeStr = (j['contentType'] ?? '').toString();
    final contentType =
        typeStr == 'short' ? SaveContentType.short : SaveContentType.feed;

    return SaveModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      userId: (j['userId'] ?? '').toString(),
      contentId: (j['contentId'] ?? '').toString(),
      contentType: contentType,
      createdAt: JsonUtils.toDateTime(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'contentId': contentId,
        'contentType': contentType.name,
        'createdAt': createdAt.toIso8601String(),
      };
}
