import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../story/models/story_viewer_item.dart';
import '../../story/models/story_viewer_user.dart';
import '../controllers/story_feed_controller.dart';
import 'story_item.dart';

class StorySection extends GetWidget<StoryFeedController> {
  const StorySection({super.key});

  List<StoryViewerUser> _buildViewerUsers() {
    final myId = controller.myUserId;
    return controller.groupedByUser
        .where((userStories) => userStories.first.user.id != myId)
        .map((userStories) {
          final first = userStories.first;
          final username = first.user.username ?? first.user.fullName ?? 'user';
          final profilePic = first.user.profilePic ?? '';
          return StoryViewerUser(
            userId: first.user.id,
            username: username,
            profileImage: profilePic,
            isNetworkImage: profilePic.startsWith('http'),
            stories: userStories.expand((s) => s.mediaUrl.map((m) => StoryViewerItem(
              storyId: s.id,
              type: m.type == 'video' ? StoryViewerType.video : StoryViewerType.image,
              media: m.url,
              isNetwork: m.url.startsWith('http'),
              time: _timeAgo(s.createdAt),
            ))).toList(),
          );
        })
        .toList()
      ..sort((a, b) {
        // Unseen stories first (left), seen stories last (right)
        if (a.viewed == b.viewed) return 0;
        return a.viewed ? 1 : -1;
      });
  }

  static String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: Obx(() {
        final viewerUsers = _buildViewerUsers();
        return ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            const CurrentUserStoryItem(),
            ...List.generate(viewerUsers.length, (i) {
              final vu = viewerUsers[i];
              return StoryItem(
                username: vu.username,
                imageUrl: vu.profileImage.isNotEmpty ? vu.profileImage : null,
                isNetworkImage: vu.isNetworkImage,
                hasStory: true,
                isViewed: vu.viewed,
                allUsers: viewerUsers,
                userIndex: i,
              );
            }),
          ],
        );
      }),
    );
  }
}
