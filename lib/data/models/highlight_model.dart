import '../../core/utils/json_util.dart';

class HighlightModel {
  const HighlightModel({
    required this.id,
    required this.userId,
    required this.title,
    this.coverUrl,
    this.storyIds = const [],
    required this.createdAt,
  });
  final String id;
  final String userId;
  final String title;
  final String? coverUrl;
  final List<String> storyIds;
  final DateTime createdAt;

  factory HighlightModel.fromJson(Map<String, dynamic> j) => HighlightModel(
    id: (j['id'] ?? j['_id'] ?? '').toString(),
    userId: (j['userId'] ?? '').toString(),
    title: (j['title'] ?? '').toString(),
    coverUrl: j['coverUrl'] as String?,
    storyIds: (j['storyIds'] as List? ?? []).map((e) => e.toString()).toList(),
    createdAt: JsonUtils.toDateTime(j['createdAt']),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'title': title,
    'coverUrl': coverUrl,
    'storyIds': storyIds,
    'createdAt': createdAt.toIso8601String(),
  };
}
