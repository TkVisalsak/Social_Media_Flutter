enum StoryViewerType { image, video }

class StoryViewerItem {
  final String storyId;
  final StoryViewerType type;
  final String media;
  final bool isNetwork;
  final String time;

  const StoryViewerItem({
    required this.storyId,
    required this.type,
    required this.media,
    this.isNetwork = true,
    required this.time,
  });
}
