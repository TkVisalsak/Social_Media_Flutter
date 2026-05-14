import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/message_model.dart';
import '../controllers/message_controller.dart';

class ChatMessageTile extends StatelessWidget {
  final ConversationModel conversation;
  final DirectController  controller;
  final VoidCallback      onTap;

  const ChatMessageTile({
    super.key,
    required this.conversation,
    required this.controller,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final name   = controller.displayName(conversation);
    final avatar = controller.displayAvatar(conversation);
    final preview = controller.previewText(conversation);
    final time    = controller.previewTime(conversation);

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Row(
          children: [
            // Avatar with online dot
            Obx(() {
              final otherId = controller.otherMember(conversation)?.id ?? '';
              final online = controller.onlineUserIds.contains(otherId);
              return Stack(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: avatar != null && avatar.isNotEmpty ? NetworkImage(avatar) : null,
                    child: avatar == null || avatar.isEmpty
                        ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                            style: const TextStyle(fontWeight: FontWeight.bold))
                        : null,
                  ),
                  if (online)
                    Positioned(
                      bottom: 1, right: 1,
                      child: Container(
                        width: 13, height: 13,
                        decoration: BoxDecoration(
                          color: const Color(0xFF31A24C),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(width: 14),

            // Name + preview
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.black)),
                  const SizedBox(height: 4),
                  Text(preview,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400)),
                ],
              ),
            ),

            // Time
            Text(time,
                style: const TextStyle(fontSize: 12, color: Color(0xFF8E939A), fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
