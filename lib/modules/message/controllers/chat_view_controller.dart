import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/socket_service.dart';
import '../../../data/models/message_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/message_repository.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isMe;
  final bool isImage;
  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    this.isImage = false,
  });
}

class ChatViewController extends GetxController {
  ChatViewController(this._repo, this._socket);

  final MessageRepository _repo;
  final SocketService     _socket;

  final messages          = <ChatMessage>[].obs;
  final messageController = TextEditingController();
  final scrollController  = ScrollController();
  final displayName       = 'Chat'.obs;
  final displayAvatar     = RxnString();
  final isLoading         = false.obs;
  final isSending         = false.obs;
  final isMutual          = true.obs;
  final canSend           = true.obs;

  String? _myId;
  String? _otherUserId;
  String? _conversationId;

  String? get otherUserId => _otherUserId;
  StreamSubscription<Map<String, dynamic>>? _msgSub;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is ConversationModel) {
      _conversationId = args.id;
      _initFromConversation(args);
    }
  }

  Future<void> _initFromConversation(ConversationModel c) async {
    final me = await LocalStorage.user;
    _myId = me?.id;

    isMutual(c.isMutual);

    if (c.isGroup) {
      displayName.value   = c.name ?? 'Group';
      displayAvatar.value = c.avatar;
    } else {
      final other = (_myId != null
              ? c.members.firstWhereOrNull((m) => m.id != _myId)
              : null) ??
          c.members.firstOrNull;
      if (other != null) {
        _otherUserId        = other.id;
        displayName.value   = other.username ?? other.fullName ?? other.email.split('@').first;
        displayAvatar.value = other.profilePic;
      }
    }

    await _loadHistory();
    _subscribeSocket();
    if (_conversationId != null) _socket.markRead(_conversationId!);
  }

  // ── History ───────────────────────────────────────────────────

  Future<void> _loadHistory() async {
    if (_conversationId == null) return;
    isLoading(true);
    final res = await _repo.getConversationMessages(_conversationId!);
    if (res.success && res.data != null) {
      messages.assignAll(res.data!.map(_toDisplay));
      _scrollToBottom();
    }
    isLoading(false);
    _updateCanSend();
  }

  void _updateCanSend() {
    if (isMutual.value) {
      canSend(true);
      return;
    }
    final myCount    = messages.where((m) => m.isMe).length;
    final theirCount = messages.where((m) => !m.isMe).length;
    canSend(myCount == 0 || theirCount > 0);
  }

  // ── Socket ────────────────────────────────────────────────────

  void _subscribeSocket() {
    _msgSub = _socket.messageStream.listen(_onSocketMessage);
  }

  void _onSocketMessage(Map<String, dynamic> raw) {
    // Normalise the payload — backend sends the Mongoose document directly.
    final convId = (raw['conversationId'] ?? raw['conversation_id'])?.toString();
    if (convId != _conversationId) return;

    try {
      final msg   = MessageModel.fromJson(raw);
      final isMe  = msg.sender.id == _myId;

      if (isMe) {
        // Replace the earliest pending temp entry sent by me.
        final tempIdx = messages.indexWhere((m) => m.id.startsWith('_temp_') && m.isMe);
        if (tempIdx != -1) {
          messages[tempIdx] = _toDisplay(msg);
          return;
        }
      }

      // Incoming message from the other person.
      messages.add(_toDisplay(msg));
      _scrollToBottom();
      _socket.markRead(_conversationId!);
      _updateCanSend();
    } catch (_) {
      // Ignore malformed payloads.
    }
  }

  // ── Send ──────────────────────────────────────────────────────

  void sendMessage() {
    final text = messageController.text.trim();
    if (text.isEmpty || _conversationId == null || !canSend.value) return;
    messageController.clear();

    // Optimistic bubble while we wait for the server echo.
    final tempId = '_temp_${DateTime.now().millisecondsSinceEpoch}';
    messages.add(ChatMessage(id: tempId, text: text, isMe: true));
    _scrollToBottom();
    _updateCanSend();

    if (_socket.isConnected) {
      // Preferred path: socket (server saves + broadcasts newMessage back).
      _socket.sendMessage(conversationId: _conversationId!, text: text);
    } else if (_otherUserId != null) {
      // Fallback: HTTP when socket is unavailable.
      _sendViaHttp(tempId, text);
    }
  }

  Future<void> _sendViaHttp(String tempId, String text) async {
    isSending(true);
    final res = await _repo.sendMessage(_otherUserId!, text: text);
    isSending(false);
    if (res.success && res.data != null) {
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) messages[idx] = _toDisplay(res.data!);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  ChatMessage _toDisplay(MessageModel m) => ChatMessage(
        id:      m.id,
        text:    m.text ?? (m.image != null ? '📷 Photo' : ''),
        isMe:    m.sender.id == _myId,
        isImage: m.image != null && m.text == null,
      );

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (scrollController.hasClients) {
        scrollController.animateTo(
          scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void onClose() {
    _msgSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
