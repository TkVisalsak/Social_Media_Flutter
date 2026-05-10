import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_bottom_navbar.dart';
import '../../../data/models/message_model.dart';
import '../controllers/message_controller.dart';

class DirectView extends GetView<DirectController> {
  const DirectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          'Messages',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      bottomNavigationBar: const AppBottomNavBar(current: AppNavTab.chat),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _SearchBar(),
            const SizedBox(height: 8),
            const _MessagesHeader(),
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.conversations.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (controller.conversations.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        controller.error.value ??
                            'No conversations yet.\nFollow people to start chatting.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () =>
                      controller.fetchConversations(refresh: true),
                  child: ListView.separated(
                    padding: const EdgeInsets.only(bottom: 12),
                    itemCount: controller.conversations.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 2),
                    itemBuilder: (_, i) {
                      final c = controller.conversations[i];
                      return _ConversationTile(
                        conversation: c,
                        name: controller.displayName(c),
                        avatar: controller.displayAvatar(c),
                        preview: controller.previewText(c),
                        time: controller.previewTime(c),
                        isGroup: c.isGroup,
                      );
                    },
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFECECEC),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Row(
          children: [
            Icon(Icons.search, color: Colors.black45),
            SizedBox(width: 10),
            Text(
              'Search',
              style: TextStyle(color: Colors.black45, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

class _MessagesHeader extends StatelessWidget {
  const _MessagesHeader();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        children: [
          Text(
            'Message',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ConversationModel conversation;
  final String name;
  final String? avatar;
  final String preview;
  final String time;
  final bool isGroup;

  const _ConversationTile({
    required this.conversation,
    required this.name,
    required this.avatar,
    required this.preview,
    required this.time,
    required this.isGroup,
  });

  @override
  Widget build(BuildContext context) {
    final hasAvatar = avatar != null && avatar!.trim().isNotEmpty;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';

    return Material(
      color: Colors.white,
      child: InkWell(
        onTap: () {
          Get.snackbar(
            'Chat',
            'Open chat with $name',
            snackPosition: SnackPosition.BOTTOM,
          );
        },
        child: Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: Colors.grey.shade300,
                backgroundImage: hasAvatar ? NetworkImage(avatar!) : null,
                child: hasAvatar
                    ? null
                    : Text(
                        initial,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isGroup)
                          const Padding(
                            padding: EdgeInsets.only(left: 4),
                            child: Icon(
                              Icons.group,
                              size: 14,
                              color: Colors.black38,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            style: const TextStyle(
                              color: Colors.black54,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '· $time',
                          style: const TextStyle(
                            color: Colors.black38,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              const Icon(Icons.photo_camera_outlined, color: Colors.black38),
            ],
          ),
        ),
      ),
    );
  }
}
