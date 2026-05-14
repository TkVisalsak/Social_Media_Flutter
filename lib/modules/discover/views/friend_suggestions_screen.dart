import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../controllers/friend_suggestions_controller.dart';

class FriendSuggestionsScreen extends GetView<FriendSuggestionsController> {
  const FriendSuggestionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'People you may know',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return RefreshIndicator(
          onRefresh: controller.refresh,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SectionHeader(title: 'Based on your interests'),
                _SuggestionsRow(controller: controller),
                const SizedBox(height: 24),
                _SectionHeader(title: 'Follow back'),
                _NotFollowingBackList(controller: controller),
              ],
            ),
          ),
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: Colors.black87,
        ),
      ),
    );
  }
}

class _SuggestionsRow extends StatelessWidget {
  final FriendSuggestionsController controller;
  const _SuggestionsRow({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final users = controller.suggestions;
      if (users.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'No suggestions right now',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        );
      }
      return SizedBox(
        height: 160,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: users.length,
          separatorBuilder: (_, __) => const SizedBox(width: 12),
          itemBuilder: (context, index) {
            return _SuggestionCard(user: users[index]);
          },
        ),
      );
    });
  }
}

class _SuggestionCard extends StatelessWidget {
  final UserModel user;
  const _SuggestionCard({required this.user});

  @override
  Widget build(BuildContext context) {
    final name = user.fullName ?? user.username ?? 'Unknown';
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.OTHER_PROFILE, arguments: user),
      child: SizedBox(
        width: 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundImage: user.profilePic != null && user.profilePic!.isNotEmpty
                  ? NetworkImage(user.profilePic!)
                  : null,
              backgroundColor: Colors.grey[200],
              child: user.profilePic == null || user.profilePic!.isEmpty
                  ? const Icon(Icons.person, size: 36, color: Colors.grey)
                  : null,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 90,
              child: Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 28,
              child: ElevatedButton(
                onPressed: () => Get.toNamed(AppRoutes.OTHER_PROFILE, arguments: user),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
                child: const Text('Follow'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NotFollowingBackList extends StatelessWidget {
  final FriendSuggestionsController controller;
  const _NotFollowingBackList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final users = controller.notFollowingBack;
      if (users.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            'Everyone who follows you is already being followed back',
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
        );
      }
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: users.length,
        itemBuilder: (context, index) {
          return _FollowBackRow(
            user: users[index],
            onFollow: () => controller.followUser(users[index].id),
          );
        },
      );
    });
  }
}

class _FollowBackRow extends StatelessWidget {
  final UserModel user;
  final VoidCallback onFollow;
  const _FollowBackRow({required this.user, required this.onFollow});

  @override
  Widget build(BuildContext context) {
    final name = user.fullName ?? user.username ?? 'Unknown';
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.OTHER_PROFILE, arguments: user),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundImage: user.profilePic != null && user.profilePic!.isNotEmpty
                  ? NetworkImage(user.profilePic!)
                  : null,
              backgroundColor: Colors.grey[200],
              child: user.profilePic == null || user.profilePic!.isEmpty
                  ? const Icon(Icons.person, size: 24, color: Colors.grey)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Follows you',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: onFollow,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.black87,
                side: const BorderSide(color: Colors.black26),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
              child: const Text('Follow back'),
            ),
          ],
        ),
      ),
    );
  }
}
