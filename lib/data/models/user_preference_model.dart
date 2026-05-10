import '../../core/utils/json_util.dart';

class UserPreferenceModel {
  const UserPreferenceModel({
    required this.id,
    required this.userId,
    this.activeStatus = false,
    this.mute = false,
    this.notification = true,
  });

  final String id;
  final String userId;
  final bool activeStatus;
  final bool mute;
  final bool notification;

  factory UserPreferenceModel.fromJson(Map<String, dynamic> j) {
    final userRaw = j['User'] ?? j['userId'] ?? j['user'];
    final userId = userRaw is Map
        ? (userRaw['_id'] ?? userRaw['id'] ?? '').toString()
        : userRaw?.toString() ?? '';

    return UserPreferenceModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      userId: userId,
      activeStatus: JsonUtils.toBool(j['ActiveStatus'] ?? j['activeStatus']),
      mute: JsonUtils.toBool(j['mute']),
      notification: j['notification'] != null
          ? JsonUtils.toBool(j['notification'])
          : true,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'activeStatus': activeStatus,
        'mute': mute,
        'notification': notification,
      };

  UserPreferenceModel copyWith({
    bool? activeStatus,
    bool? mute,
    bool? notification,
  }) =>
      UserPreferenceModel(
        id: id,
        userId: userId,
        activeStatus: activeStatus ?? this.activeStatus,
        mute: mute ?? this.mute,
        notification: notification ?? this.notification,
      );
}
