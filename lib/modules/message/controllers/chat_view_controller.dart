import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/socket_service.dart';
import '../../../data/models/message_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/message_repository.dart';

class ChatMessage {
  final String  id;
  final String  text;
  final bool    isMe;
  final bool    isImage;
  final String? imageUrl;    // local file path or network URL
  final String? senderName;
  final String? senderAvatar;
  ChatMessage({
    required this.id,
    required this.text,
    required this.isMe,
    this.isImage      = false,
    this.imageUrl     ,
    this.senderName   ,
    this.senderAvatar ,
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
  final isGroup           = false.obs;
  final groupMembers      = <UserModel>[];

  String? _myId;
  String? _otherUserId;
  String? _conversationId;

  String? get otherUserId => _otherUserId;
  StreamSubscription<Map<String, dynamic>>? _msgSub;
  StreamSubscription<Map<String, dynamic>>? _deleteSub;

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
    isGroup(c.isGroup);
    if (c.isGroup) groupMembers.addAll(c.members);

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
    _msgSub    = _socket.messageStream.listen(_onSocketMessage);
    _deleteSub = _socket.deletedMessageStream.listen(_onSocketDelete);
  }

  void _onSocketDelete(Map<String, dynamic> raw) {
    final msgId  = raw['messageId']?.toString();
    final convId = (raw['conversationId'])?.toString();
    if (msgId == null || convId != _conversationId) return;
    messages.removeWhere((m) => m.id == msgId);
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
    final res = _conversationId != null
        ? await _repo.sendConversationMessage(_conversationId!, text: text)
        : await _repo.sendMessage(_otherUserId!, text: text);
    isSending(false);
    if (res.success && res.data != null) {
      final idx = messages.indexWhere((m) => m.id == tempId);
      if (idx != -1) messages[idx] = _toDisplay(res.data!);
    }
  }

  /// Called when the user picks an image from the gallery or camera.
  Future<void> sendImageFile(String filePath) async {
    if (_conversationId == null) return;

    final tempId = '_temp_img_${DateTime.now().millisecondsSinceEpoch}';
    messages.add(ChatMessage(id: tempId, text: '📷 Photo', isMe: true, isImage: true, imageUrl: filePath));
    _scrollToBottom();

    isSending(true);
    try {
      final bytes = await File(filePath).readAsBytes();
      final base64Image = 'data:image/jpeg;base64,${base64Encode(bytes)}';

      final res = await _repo.sendConversationMessage(
        _conversationId!,
        image: base64Image,
      );

      if (res.success && res.data != null) {
        final idx = messages.indexWhere((m) => m.id == tempId);
        if (idx != -1) messages[idx] = _toDisplay(res.data!);
      } else {
        messages.removeWhere((m) => m.id == tempId);
        Get.snackbar('Error', res.error ?? 'Failed to send image',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      messages.removeWhere((m) => m.id == tempId);
      Get.snackbar('Error', 'Failed to send image',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSending(false);
    }
  }

  // ── Delete ────────────────────────────────────────────────────

  Future<void> deleteMessage(String messageId) async {
    // Optimistically remove from the list.
    final removed = messages.firstWhereOrNull((m) => m.id == messageId);
    messages.removeWhere((m) => m.id == messageId);

    final res = await _repo.deleteMessage(messageId);
    if (!res.success) {
      // Restore on failure.
      if (removed != null) messages.add(removed);
      Get.snackbar('Error', res.error ?? 'Failed to delete message',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // ── Helpers ───────────────────────────────────────────────────

  ChatMessage _toDisplay(MessageModel m) {
    final mine = m.sender.id == _myId;
    return ChatMessage(
      id:           m.id,
      text:         m.text ?? (m.image != null ? '📷 Photo' : ''),
      isMe:         mine,
      isImage:      m.image != null && m.text == null,
      imageUrl:     m.image,
      senderName:   mine ? null : (m.sender.username ?? m.sender.fullName),
      senderAvatar: mine ? null : m.sender.profilePic,
    );
  }

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
    _deleteSub?.cancel();
    messageController.dispose();
    scrollController.dispose();
    super.onClose();
  }
}
