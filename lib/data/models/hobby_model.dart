class HobbyModel {
  const HobbyModel({
    required this.id,
    required this.name,
    this.emoji,
  });

  final String id;
  final String name;
  final String? emoji;

  factory HobbyModel.fromJson(Map<String, dynamic> json) {
    return HobbyModel(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? '').toString(),
      emoji: json['emoji']?.toString(),
    );
  }
}
