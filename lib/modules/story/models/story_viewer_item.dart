enum StoryViewerType { image, video }

class StoryViewerItem {
  final StoryViewerType type;
  final String media;
  final bool isNetwork;
  final String time;

  const StoryViewerItem({
    required this.type,
    required this.media,
    this.isNetwork = true,
    required this.time,
  });
}
