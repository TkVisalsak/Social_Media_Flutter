import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/chat_view_controller.dart';
import '../controllers/message_controller.dart';
import 'group_info_screen.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<ChatViewController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Obx(() {
          final avatar = ctrl.displayAvatar.value;
          final name = ctrl.displayName.value;
          final group = ctrl.isGroup.value;
          final directCtrl = Get.isRegistered<DirectController>()
              ? Get.find<DirectController>()
              : null;
          final otherId = ctrl.otherUserId ?? '';
          final online = !group && directCtrl != null && otherId.isNotEmpty
              ? directCtrl.onlineUserIds.contains(otherId)
              : false;

          final row = Row(
            children: [
              Stack(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: avatar != null && avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                    child: avatar == null || avatar.isEmpty
                        ? Text(
                            name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 13),
                          )
                        : null,
                  ),
                  if (online)
                    Positioned(
                      bottom: 0, right: 0,
                      child: Container(
                        width: 10, height: 10,
                        decoration: BoxDecoration(
                          color: const Color(0xFF31A24C),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 1.5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name,
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.bold)),
                  Text(
                    group
                        ? '${ctrl.groupMembers.length} members'
                        : 'Active now',
                    style:
                        const TextStyle(color: Colors.grey, fontSize: 11)),
                ],
              ),
            ],
          );

          // Tapping avatar/name opens group info for group chats.
          if (group) {
            return GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const GroupInfoScreen()),
              ),
              child: row,
            );
          }
          return row;
        }),
        actions: [
          IconButton(
              icon: const Icon(Icons.phone_outlined, color: Colors.black),
              onPressed: () {}),
          IconButton(
              icon: const Icon(Icons.videocam_outlined, color: Colors.black),
              onPressed: () {}),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (ctrl.isLoading.value && ctrl.messages.isEmpty) {
                return const Center(child: CircularProgressIndicator());
              }
              if (ctrl.messages.isEmpty) {
                return const Center(
                  child: Text('No messages yet. Say hello!',
                      style: TextStyle(color: Colors.grey, fontSize: 15)),
                );
              }
              return ListView.builder(
                controller: ctrl.scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: ctrl.messages.length,
                itemBuilder: (context, index) {
                  final msg = ctrl.messages[index];
                  return GestureDetector(
                    onLongPress: msg.isMe
                        ? () => _showDeleteSheet(context, ctrl, msg.id)
                        : null,
                    child: _buildMessage(
                      msg,
                      showSender: ctrl.isGroup.value,
                    ),
                  );
                },
              );
            }),
          ),
          _buildMessageInput(ctrl),
        ],
      ),
    );
  }

  void _showDeleteSheet(
      BuildContext context, ChatViewController ctrl, String messageId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline_rounded,
                  color: Colors.red),
              title: const Text('Delete message',
                  style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                ctrl.deleteMessage(messageId);
              },
            ),
            ListTile(
              leading: const Icon(Icons.close_rounded),
              title: const Text('Cancel'),
              onTap: () => Get.back(),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildMessage(ChatMessage msg, {required bool showSender}) {
    final isMe = msg.isMe;

    Widget bubble = msg.isImage && msg.imageUrl != null
        ? _buildImageBubble(msg)
        : _buildTextBubble(msg);

    // For group chats, prepend avatar + name to received messages.
    if (showSender && !isMe) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.grey[300],
              backgroundImage: msg.senderAvatar != null &&
                      msg.senderAvatar!.isNotEmpty
                  ? NetworkImage(msg.senderAvatar!) as ImageProvider
                  : null,
              child: msg.senderAvatar == null || msg.senderAvatar!.isEmpty
                  ? Text(
                      (msg.senderName ?? '?').isNotEmpty
                          ? (msg.senderName!)[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.bold),
                    )
                  : null,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (msg.senderName != null && msg.senderName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(left: 4, bottom: 2),
                    child: Text(
                      msg.senderName!,
                      style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500),
                    ),
                  ),
                bubble,
              ],
            ),
          ],
        ),
      );
    }

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: bubble,
    );
  }

  Widget _buildTextBubble(ChatMessage msg) {
    final isMe = msg.isMe;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      constraints: BoxConstraints(maxWidth: Get.width * 0.7),
      decoration: BoxDecoration(
        color: isMe ? const Color(0xFF3797F0) : const Color(0xFFEFEFEF),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        msg.text,
        style: TextStyle(
            color: isMe ? Colors.white : Colors.black, fontSize: 15),
      ),
    );
  }

  Widget _buildImageBubble(ChatMessage msg) {
    final url = msg.imageUrl!;
    final isLocal = !url.startsWith('http');

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      constraints: BoxConstraints(maxWidth: Get.width * 0.65),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.grey[200],
      ),
      clipBehavior: Clip.antiAlias,
      child: isLocal
          ? Image.file(File(url), fit: BoxFit.cover)
          : Image.network(
              url,
              fit: BoxFit.cover,
              loadingBuilder: (_, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      width: 180,
                      height: 180,
                      child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2)),
                    ),
              errorBuilder: (_, __, ___) => const SizedBox(
                width: 180,
                height: 120,
                child: Icon(Icons.broken_image_outlined, color: Colors.grey),
              ),
            ),
    );
  }

  Widget _buildMessageInput(ChatViewController ctrl) {
    return Obx(() {
      if (!ctrl.canSend.value) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: Colors.grey[200]!)),
          ),
          child: SafeArea(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline, size: 16, color: Colors.grey[500]),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Waiting for ${ctrl.displayName.value} to reply…',
                    style: TextStyle(color: Colors.grey[500], fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }

      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Colors.grey[200]!)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!ctrl.isMutual.value && ctrl.messages.where((m) => m.isMe).isEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    'You can send 1 message to start a conversation.',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              Row(
                children: [
                  // Gallery picker
                  IconButton(
                    icon: const Icon(Icons.photo_outlined,
                        color: Color(0xFF3797F0), size: 26),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (picked != null) ctrl.sendImageFile(picked.path);
                    },
                  ),
                  // Camera
                  IconButton(
                    icon: const Icon(Icons.camera_alt_outlined,
                        color: Color(0xFF3797F0), size: 26),
                    onPressed: () async {
                      final picker = ImagePicker();
                      final picked = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      if (picked != null) ctrl.sendImageFile(picked.path);
                    },
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: TextField(
                        controller: ctrl.messageController,
                        decoration: const InputDecoration(
                            hintText: 'Message...', border: InputBorder.none),
                        onSubmitted: (_) => ctrl.sendMessage(),
                      ),
                    ),
                  ),
                  Obx(() => IconButton(
                        icon: ctrl.isSending.value
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF3797F0)),
                              )
                            : const Icon(Icons.send, color: Color(0xFF3797F0)),
                        onPressed: ctrl.isSending.value ? null : ctrl.sendMessage,
                      )),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }
}
