import 'user_model.dart';
import '../../core/utils/json_util.dart';

class MessageModel {
  const MessageModel({
    required this.id,
    required this.conversationId,
    required this.sender,
    this.text,
    this.image,
    this.readBy = const [],
    required this.createdAt,
  });

  final String id;
  final String conversationId;
  final UserModel sender;
  final String? text;
  final String? image;
  final List<String> readBy;
  final DateTime createdAt;

  factory MessageModel.fromJson(Map<String, dynamic> j) {
    final senderRaw = j['sender'] ?? j['senderId'];
    final senderJson = senderRaw is Map
        ? Map<String, dynamic>.from(senderRaw)
        : {'_id': senderRaw?.toString() ?? ''};

    return MessageModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      conversationId:
          (j['conversationId'] ?? j['conversation_id'] ?? '').toString(),
      sender: UserModel.fromJson(senderJson),
      text: JsonUtils.nullableString(j['text']),
      image: JsonUtils.nullableString(j['image']),
      readBy: (j['readBy'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: JsonUtils.toDateTime(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'conversationId': conversationId,
        'sender': sender.toJson(),
        'text': text,
        'image': image,
        'readBy': readBy,
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is MessageModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}

class ConversationModel {
  const ConversationModel({
    required this.id,
    required this.members,
    this.isGroup = false,
    this.isMutual = true,
    this.name,
    this.avatar,
    this.admin,
    this.lastMessage,
    required this.createdAt,
  });

  final String id;
  final List<UserModel> members;
  final bool isGroup;
  final bool isMutual;
  final String? name;
  final String? avatar;
  final UserModel? admin;
  final MessageModel? lastMessage;
  final DateTime createdAt;

  factory ConversationModel.fromJson(Map<String, dynamic> j) {
    final adminRaw = j['admin'];
    UserModel? admin;
    if (adminRaw is Map) {
      admin = UserModel.fromJson(Map<String, dynamic>.from(adminRaw));
    } else if (adminRaw is String && adminRaw.isNotEmpty) {
      admin = UserModel.fromJson({'_id': adminRaw});
    }

    final lastMsgRaw = j['lastMessage'];
    MessageModel? lastMessage;
    if (lastMsgRaw is Map) {
      lastMessage =
          MessageModel.fromJson(Map<String, dynamic>.from(lastMsgRaw));
    }

    return ConversationModel(
      id: (j['id'] ?? j['_id'] ?? '').toString(),
      isGroup: JsonUtils.toBool(j['isGroup']),
      isMutual: j['isMutual'] as bool? ?? true,
      name: JsonUtils.nullableString(j['name']),
      avatar: JsonUtils.nullableString(j['avatar']),
      admin: admin,
      members: (j['members'] as List? ?? [])
          .map((e) => e is Map
              ? UserModel.fromJson(Map<String, dynamic>.from(e))
              : UserModel.fromJson({'_id': e.toString()}))
          .toList(),
      lastMessage: lastMessage,
      createdAt: JsonUtils.toDateTime(j['createdAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'isGroup': isGroup,
        'isMutual': isMutual,
        'name': name,
        'avatar': avatar,
        'admin': admin?.toJson(),
        'members': members.map((m) => m.toJson()).toList(),
        'lastMessage': lastMessage?.toJson(),
        'createdAt': createdAt.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ConversationModel && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
