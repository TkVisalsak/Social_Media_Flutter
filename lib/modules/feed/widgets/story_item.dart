import 'package:flutter/material.dart';

import '../../../shared/widgets/story_avatar.dart';
import '../../story/models/story_viewer_user.dart';
import '../../story/screens/create_story_screen.dart';
import '../../story/views/story_viewer_screen.dart';

class StoryItem extends StatelessWidget {
  final String  username;
  final String? imageUrl;
  final bool    isNetworkImage;
  final bool    hasStory;
  final bool    isViewed;
  final bool    isCurrentUser;
  final List<StoryViewerUser> allUsers;
  final int     userIndex;

  const StoryItem({
    super.key,
    required this.username,
    this.imageUrl,
    this.isNetworkImage = true,
    this.hasStory       = false,
    this.isCurrentUser  = false,
    this.isViewed       = false,
    this.allUsers       = const [],
    this.userIndex      = 0,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _handleTap(context),
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            StoryAvatar(
              imagePath:      imageUrl,
              isNetworkImage: isNetworkImage,
              username:       username,
              radius:         30,
              hasRing:        hasStory,
              isViewed:       isViewed,
              showAddBadge:   isCurrentUser && !hasStory,
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 72,
              child: Text(
                isCurrentUser ? 'Your story' : username,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleTap(BuildContext context) {
    if (isCurrentUser) {
      if (hasStory && allUsers.isNotEmpty) {
        _openViewer(context);
      } else {
        Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateStoryScreen()));
      }
    } else {
      _openViewer(context);
    }
  }

  void _openViewer(BuildContext context) {
    if (allUsers.isEmpty) return;
    Navigator.push(context, MaterialPageRoute(
      builder: (_) => StoryViewerScreen(
        users: allUsers,
        initialUserIndex: userIndex.clamp(0, allUsers.length - 1),
      ),
    ));
  }
}

class CurrentUserStoryItem extends StatelessWidget {
  final String? imagePath;
  final bool    isNetworkImage;
  const CurrentUserStoryItem({
    super.key,
    this.imagePath,
    this.isNetworkImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const CreateStoryScreen())),
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            StoryAvatar(
              imagePath:      imagePath,
              isNetworkImage: isNetworkImage,
              username:       'You',
              radius:         30,
              showAddBadge:   true,
            ),
            const SizedBox(height: 8),
            const SizedBox(
              width: 72,
              child: Text('Your story', textAlign: TextAlign.center, overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }
}
