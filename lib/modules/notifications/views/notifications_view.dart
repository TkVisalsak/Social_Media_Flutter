import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/notification_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Notifications',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          Obx(() {
            final hasUnread = controller.notifications.any((n) => !n.isRead);
            if (!hasUnread) return const SizedBox.shrink();
            return TextButton(
              onPressed: controller.markAllRead,
              child: const Text('Mark all read',
                  style: TextStyle(color: Color(0xFF3797F0), fontWeight: FontWeight.w600)),
            );
          }),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 64, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(controller.error.value ?? 'No notifications yet',
                    style: const TextStyle(color: Colors.grey, fontSize: 15)),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: controller.fetch,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: controller.notifications.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, indent: 72, color: Colors.grey[100]),
            itemBuilder: (_, i) {
              final n = controller.notifications[i];
              return _NotificationTile(
                notification: n,
                onTap: () => controller.markRead(n.id),
              );
            },
          ),
        );
      }),
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final NotificationModel notification;
  final VoidCallback onTap;

  const _NotificationTile({required this.notification, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final actor  = notification.actor;
    final name   = actor.username ?? actor.fullName ?? actor.email.split('@').first;
    final avatar = actor.profilePic;
    final unread = !notification.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: unread ? const Color(0xFFF0F7FF) : Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatar != null && avatar.isNotEmpty
                      ? NetworkImage(avatar)
                      : null,
                  child: avatar == null || avatar.isEmpty
                      ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16))
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _typeColor(notification.type),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                    child: Icon(_typeIcon(notification.type),
                        size: 11, color: Colors.white),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 14),
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.4),
                      children: [
                        TextSpan(
                          text: name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' ${_typeLabel(notification.type)}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    _timeAgo(notification.createdAt),
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            if (unread)
              Container(
                width: 9,
                height: 9,
                margin: const EdgeInsets.only(left: 8),
                decoration: const BoxDecoration(
                  color: Color(0xFF3797F0),
                  shape: BoxShape.circle,
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'like':        return 'liked your post.';
      case 'comment':     return 'commented on your post.';
      case 'follow':      return 'started following you.';
      case 'repost':      return 'reposted your content.';
      case 'tag':         return 'tagged you in a post.';
      case 'story_reply': return 'replied to your story.';
      default:            return 'interacted with you.';
    }
  }

  IconData _typeIcon(String type) {
    switch (type) {
      case 'like':        return Icons.favorite_rounded;
      case 'comment':     return Icons.chat_bubble_rounded;
      case 'follow':      return Icons.person_add_rounded;
      case 'repost':      return Icons.repeat_rounded;
      case 'tag':         return Icons.alternate_email_rounded;
      case 'story_reply': return Icons.reply_rounded;
      default:            return Icons.notifications_rounded;
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'like':        return const Color(0xFFFF4D6D);
      case 'comment':     return const Color(0xFF3797F0);
      case 'follow':      return const Color(0xFF45BD62);
      case 'repost':      return const Color(0xFFFF9500);
      case 'tag':         return const Color(0xFF00BCD4);
      case 'story_reply': return const Color(0xFF8B5CF6);
      default:            return Colors.grey;
    }
  }

  static String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays >= 7)     return '${(diff.inDays / 7).floor()}w';
    if (diff.inDays >= 1)     return '${diff.inDays}d';
    if (diff.inHours >= 1)    return '${diff.inHours}h';
    if (diff.inMinutes >= 1)  return '${diff.inMinutes}m';
    return 'now';
  }
}
