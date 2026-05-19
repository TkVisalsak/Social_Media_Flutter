import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../controllers/chat_view_controller.dart';

class GroupInfoScreen extends StatelessWidget {
  const GroupInfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl    = Get.find<ChatViewController>();
    final name    = ctrl.displayName.value;
    final avatar  = ctrl.displayAvatar.value;
    final members = ctrl.groupMembers;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Group Info',
          style: TextStyle(
              color: Colors.black, fontSize: 17, fontWeight: FontWeight.w600),
        ),
      ),
      body: ListView(
        children: [
          // ── Group avatar + name ──────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 28),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 48,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: avatar != null && avatar.isNotEmpty
                      ? NetworkImage(avatar) as ImageProvider
                      : null,
                  child: avatar == null || avatar.isEmpty
                      ? Text(
                          name.isNotEmpty ? name[0].toUpperCase() : 'G',
                          style: const TextStyle(
                              fontSize: 36, fontWeight: FontWeight.bold,
                              color: Colors.grey),
                        )
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  '${members.length} member${members.length == 1 ? '' : 's'}',
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          // ── Members section header ───────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Members',
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.4),
            ),
          ),

          // ── Member list ──────────────────────────────────────────
          ...members.map((u) => _MemberTile(user: u)),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final UserModel user;
  const _MemberTile({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user.fullName ?? user.username ?? 'Unknown';
    final sub  = user.username != null && user.fullName != null
        ? '@${user.username}'
        : null;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      onTap: () => Get.toNamed(AppRoutes.OTHER_PROFILE, arguments: user),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: Colors.grey[200],
        backgroundImage: user.profilePic != null && user.profilePic!.isNotEmpty
            ? NetworkImage(user.profilePic!) as ImageProvider
            : null,
        child: user.profilePic == null || user.profilePic!.isEmpty
            ? Text(
                name.isNotEmpty ? name[0].toUpperCase() : '?',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.grey),
              )
            : null,
      ),
      title: Text(
        name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      subtitle: sub != null
          ? Text(sub,
              style: const TextStyle(color: Colors.grey, fontSize: 13))
          : null,
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
    );
  }
}
