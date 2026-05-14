import 'dart:async';

import 'package:get/get.dart';

import '../../../core/services/socket_service.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/message_repository.dart';

class DirectController extends GetxController {
  DirectController(this._repo, this._socket);
  final MessageRepository _repo;
  final SocketService     _socket;

  final conversations  = <ConversationModel>[].obs;
  final isLoading      = false.obs;
  final error          = RxnString();
  final myUserId       = RxnString();
  final onlineUserIds  = <String>{}.obs;

  StreamSubscription<List<String>>? _onlineSub;

  @override
  void onInit() {
    super.onInit();
    _loadMe();
    fetchConversations();
    _onlineSub = _socket.onlineUsersStream.listen(
      (ids) => onlineUserIds.assignAll(ids),
    );
  }

  Future<void> _loadMe() async {
    final me = await LocalStorage.user;
    myUserId.value = me?.id;
  }

  Future<void> fetchConversations({bool refresh = false}) async {
    if (isLoading.value) return;
    isLoading(true);
    error(null);
    final res = await _repo.getConversations();
    if (res.success && res.data != null) {
      conversations.assignAll(res.data!);
    } else {
      error(res.error);
    }
    isLoading(false);
  }

  /// Returns the "other" member for a DM, or null for groups.
  UserModel? otherMember(ConversationModel c) {
    if (c.isGroup) return null;
    final mine = myUserId.value;
    if (mine == null) {
      return c.members.isNotEmpty ? c.members.first : null;
    }
    return c.members.firstWhereOrNull((m) => m.id != mine) ??
        (c.members.isNotEmpty ? c.members.first : null);
  }

  String displayName(ConversationModel c) {
    if (c.isGroup) return c.name ?? 'Group';
    final other = otherMember(c);
    if (other == null) return 'Direct message';
    return other.username ?? other.fullName ?? other.email.split('@').first;
  }

  String? displayAvatar(ConversationModel c) {
    if (c.isGroup) return c.avatar;
    return otherMember(c)?.profilePic;
  }

  String previewText(ConversationModel c) {
    final last = c.lastMessage;
    if (last == null) return 'Start a conversation';
    if (last.text != null && last.text!.trim().isNotEmpty) return last.text!;
    if (last.image != null && last.image!.isNotEmpty) return '📷 Photo';
    return '';
  }

  bool isOnline(String userId) => onlineUserIds.contains(userId);

  String previewTime(ConversationModel c) {
    final t = c.lastMessage?.createdAt ?? c.createdAt;
    final diff = DateTime.now().difference(t);
    if (diff.inDays >= 7) return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  void onClose() {
    _onlineSub?.cancel();
    super.onClose();
  }
}
