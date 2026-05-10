import 'user_model.dart';
import '../../core/utils/json_util.dart';

class FollowModel {
  const FollowModel({
    required this.id,
    required this.follower,
    required this.following,
    required this.createdAt,
  });

  final String id;
  final UserModel follower;
  final UserModel following;
  final DateTime createdAt;

  factory FollowModel.fromJson(Map<String, dynamic> j) {
    UserModel _parseUser(dynamic raw) {
      if (raw is Map) return UserModel.fromJson(Map<String, dynamic>.from(raw));
      return UserModel.fromJson({'_id': raw?.toString() ?? ''});
    }

    return FollowModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      follower: _parseUser(j['follower']),
      following: _parseUser(j['following']),
      createdAt: JsonUtils.toDateTime(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'follower': follower.toJson(),
        'following': following.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };
}
