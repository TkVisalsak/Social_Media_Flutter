import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/story_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../story/views/story_viewer_screen.dart';
import '../controllers/story_feed_controller.dart';
import 'story_item.dart';

class StorySection extends StatelessWidget {
  const StorySection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<StoryFeedController>();

    return SizedBox(
      height: 110,
      child: Obx(() {
        if (controller.isLoading.value && controller.stories.isEmpty) {
          return const Center(
            child: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }

        final groups = controller.groupedByUser;

        return ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: groups.length + 1,
          itemBuilder: (_, i) {
            if (i == 0) return _buildOwnStory(context);
            final group = groups[i - 1];
            final user = group.first.user;
            return StoryItem(
              username: user.username ?? user.email.split('@').first,
              imageUrl: user.profilePic,
              hasStory: true,
              onTap: () => _openViewer(context, groups, i - 1),
            );
          },
        );
      }),
    );
  }

  Widget _buildOwnStory(BuildContext context) {
    return FutureBuilder<UserModel?>(
      future: LocalStorage.user,
      builder: (context, snap) {
        final me = snap.data;
        return StoryItem(
          username: me?.username ?? 'You',
          imageUrl: me?.profilePic,
          isCurrentUser: true,
          hasStory: false,
          onTap: () {
            Get.snackbar(
              'Story',
              'Create-story flow not wired yet',
              snackPosition: SnackPosition.BOTTOM,
            );
          },
        );
      },
    );
  }

  void _openViewer(
    BuildContext context,
    List<List<StoryModel>> groups,
    int initialUserIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => StoryViewerScreen(
          userStories: groups,
          initialUserIndex: initialUserIndex,
        ),
      ),
    );
  }
}
