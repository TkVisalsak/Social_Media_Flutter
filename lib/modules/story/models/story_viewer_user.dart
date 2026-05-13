import 'story_viewer_item.dart';

class StoryViewerUser {
  bool viewed;
  final String username;
  final String profileImage;
  final bool isNetworkImage;
  final List<StoryViewerItem> stories;

  StoryViewerUser({
    required this.username,
    required this.profileImage,
    this.isNetworkImage = true,
    required this.stories,
    this.viewed = false,
  });
}
