import 'user_model.dart';
import '../../core/utils/json_util.dart';

class NotificationModel {
  const NotificationModel({
    required this.id,
    required this.type,
    required this.actor,
    this.targetId,
    this.targetType,
    this.message,
    this.isRead = false,
    required this.createdAt,
  });

  final String id;

  /// 'like' | 'comment' | 'follow' | 'repost' | 'tag' | 'story_reply'
  final String type;
  final UserModel actor;

  /// The content (post/short/comment) that triggered the notification.
  final String? targetId;
  final String? targetType; // 'feed' | 'short' | 'comment'

  final String? message;
  final bool isRead;
  final DateTime createdAt;

  factory NotificationModel.fromJson(Map<String, dynamic> j) {
    final actorRaw = j['actor'] ?? j['from'] ?? j['sender'] ?? j['userId'];
    final actorJson = actorRaw is Map
        ? Map<String, dynamic>.from(actorRaw)
        : {'_id': actorRaw?.toString() ?? ''};

    return NotificationModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      type: (j['type'] ?? '').toString(),
      actor: UserModel.fromJson(actorJson),
      targetId: JsonUtils.nullableString(j['targetId'] ?? j['contentId']),
      targetType:
          JsonUtils.nullableString(j['targetType'] ?? j['contentType']),
      message: JsonUtils.nullableString(j['message']),
      isRead: JsonUtils.toBool(j['isRead'] ?? j['read']),
      createdAt: JsonUtils.toDateTime(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'actor': actor.toJson(),
        'targetId': targetId,
        'targetType': targetType,
        'message': message,
        'isRead': isRead,
        'createdAt': createdAt.toIso8601String(),
      };

  NotificationModel copyWith({bool? isRead}) => NotificationModel(
        id: id,
        type: type,
        actor: actor,
        targetId: targetId,
        targetType: targetType,
        message: message,
        isRead: isRead ?? this.isRead,
        createdAt: createdAt,
      );
}
