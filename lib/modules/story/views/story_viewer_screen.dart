import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/story_model.dart';
import '../../../data/repositories/story_repository.dart';

/// Plays a list of users' stories. Each user has a list of [StoryModel]s
/// (one row in the home stories bar = one user's stories).
class StoryViewerScreen extends StatefulWidget {
  final List<List<StoryModel>> userStories;
  final int initialUserIndex;

  const StoryViewerScreen({
    super.key,
    required this.userStories,
    required this.initialUserIndex,
  });

  @override
  State<StoryViewerScreen> createState() => _StoryViewerScreenState();
}

class _StoryViewerScreenState extends State<StoryViewerScreen> {
  late int currentUserIndex;
  int currentStoryIndex = 0;
  int currentMediaIndex = 0;

  Timer? timer;
  bool isPaused = false;
  bool showHeart = false;
  double progress = 0;
  double dragOffset = 0;

  VideoPlayerController? videoController;

  List<StoryModel> get _userStories =>
      widget.userStories[currentUserIndex];
  StoryModel get _story => _userStories[currentStoryIndex];

  @override
  void initState() {
    super.initState();
    currentUserIndex = widget.initialUserIndex;
    _loadStory();
  }

  String? get _currentMediaUrl {
    if (_story.mediaUrl.isEmpty) return null;
    final clamped = currentMediaIndex.clamp(0, _story.mediaUrl.length - 1);
    return _story.mediaUrl[clamped].url;
  }

  String get _currentMediaType {
    if (_story.mediaUrl.isEmpty) return _story.type;
    final clamped = currentMediaIndex.clamp(0, _story.mediaUrl.length - 1);
    return _story.mediaUrl[clamped].type;
  }

  Future<void> _loadStory() async {
    timer?.cancel();
    await videoController?.dispose();
    videoController = null;
    progress = 0;

    // Best-effort view tracking — do not block the UI.
    if (Get.isRegistered<StoryRepository>()) {
      Get.find<StoryRepository>().recordView(_story.id);
    }

    final url = _currentMediaUrl;
    final type = _currentMediaType;

    if (url == null || url.isEmpty) {
      _scheduleImageProgress();
      if (mounted) setState(() {});
      return;
    }

    if (type == 'video') {
      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      videoController = controller;
      try {
        await controller.initialize();
        controller
          ..play()
          ..setLooping(false);
        if (mounted) setState(() {});
        timer = Timer.periodic(
          const Duration(milliseconds: 50),
          (_) {
            if (!mounted || videoController == null) return;
            final pos = videoController!.value.position.inMilliseconds;
            final dur = videoController!.value.duration.inMilliseconds;
            if (dur > 0) {
              setState(() => progress = pos / dur);
              if (pos >= dur) _next();
            }
          },
        );
      } catch (_) {
        _scheduleImageProgress();
        if (mounted) setState(() {});
      }
    } else {
      _scheduleImageProgress();
      if (mounted) setState(() {});
    }
  }

  void _scheduleImageProgress() {
    timer = Timer.periodic(const Duration(milliseconds: 50), (t) {
      if (!mounted) return;
      setState(() => progress += 0.01);
      if (progress >= 1) {
        t.cancel();
        _next();
      }
    });
  }

  void _next() {
    // Advance through media URLs of this story first.
    if (currentMediaIndex < _story.mediaUrl.length - 1) {
      setState(() => currentMediaIndex++);
      _loadStory();
      return;
    }
    // Then advance to the next story of this user.
    if (currentStoryIndex < _userStories.length - 1) {
      setState(() {
        currentStoryIndex++;
        currentMediaIndex = 0;
      });
      _loadStory();
      return;
    }
    // Then advance to the next user.
    if (currentUserIndex < widget.userStories.length - 1) {
      setState(() {
        currentUserIndex++;
        currentStoryIndex = 0;
        currentMediaIndex = 0;
      });
      _loadStory();
      return;
    }
    // No more — close.
    timer?.cancel();
    videoController?.dispose();
    videoController = null;
    Future.microtask(() {
      if (mounted) Navigator.of(context).pop();
    });
  }

  void _previous() {
    if (currentMediaIndex > 0) {
      setState(() => currentMediaIndex--);
      _loadStory();
      return;
    }
    if (currentStoryIndex > 0) {
      setState(() {
        currentStoryIndex--;
        currentMediaIndex = _userStories[currentStoryIndex].mediaUrl.isNotEmpty
            ? _userStories[currentStoryIndex].mediaUrl.length - 1
            : 0;
      });
      _loadStory();
      return;
    }
    if (currentUserIndex > 0) {
      setState(() {
        currentUserIndex--;
        currentStoryIndex = _userStories.length - 1;
        currentMediaIndex = _userStories[currentStoryIndex].mediaUrl.isNotEmpty
            ? _userStories[currentStoryIndex].mediaUrl.length - 1
            : 0;
      });
      _loadStory();
    }
  }

  void _pause() {
    isPaused = true;
    timer?.cancel();
    videoController?.pause();
  }

  void _resume() {
    if (!isPaused) return;
    isPaused = false;
    if (_currentMediaType == 'video' && videoController != null) {
      videoController!.play();
      timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
        if (!mounted || videoController == null) return;
        final pos = videoController!.value.position.inMilliseconds;
        final dur = videoController!.value.duration.inMilliseconds;
        if (dur > 0) {
          setState(() => progress = pos / dur);
        }
      });
    } else {
      _scheduleImageProgress();
    }
  }

  String _formatTime(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays >= 1) return '${diff.inDays}d';
    if (diff.inHours >= 1) return '${diff.inHours}h';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}m';
    return 'now';
  }

  @override
  void dispose() {
    timer?.cancel();
    videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = _story.user;
    final username =
        user.username ?? user.fullName ?? user.email.split('@').first;
    final url = _currentMediaUrl;
    final type = _currentMediaType;

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < 0) {
          _next();
        } else if (details.primaryVelocity! > 0) {
          _previous();
        }
      },
      onVerticalDragUpdate: (d) =>
          setState(() => dragOffset += d.delta.dy),
      onVerticalDragEnd: (_) {
        if (dragOffset > 120) {
          Navigator.pop(context);
        } else {
          setState(() => dragOffset = 0);
        }
      },
      onLongPressStart: (_) => _pause(),
      onLongPressEnd: (_) => _resume(),
      onDoubleTap: () {
        setState(() => showHeart = true);
        Future.delayed(const Duration(milliseconds: 700), () {
          if (mounted) setState(() => showHeart = false);
        });
      },
      child: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onTapUp: (details) {
          final width = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < width / 2) {
            _previous();
          } else {
            _next();
          }
        },
        child: Transform.translate(
          offset: Offset(0, dragOffset),
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                SizedBox.expand(
                  child: _buildMedia(url, type),
                ),
                Center(
                  child: AnimatedOpacity(
                    opacity: showHeart ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    child: AnimatedScale(
                      scale: showHeart ? 1 : 0.5,
                      duration: const Duration(milliseconds: 250),
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 110,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 55,
                  left: 16,
                  right: 16,
                  child: Column(
                    children: [
                      Row(
                        children: List.generate(
                          _userStories.length,
                          (index) => Expanded(
                            child: Container(
                              margin: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              height: 3,
                              decoration: BoxDecoration(
                                color: Colors.white24,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: FractionallySizedBox(
                                alignment: Alignment.centerLeft,
                                widthFactor: index < currentStoryIndex
                                    ? 1
                                    : index == currentStoryIndex
                                        ? progress
                                        : 0,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.white24,
                            backgroundImage: (user.profilePic != null &&
                                    user.profilePic!.isNotEmpty)
                                ? NetworkImage(user.profilePic!)
                                : null,
                            child: (user.profilePic == null ||
                                    user.profilePic!.isEmpty)
                                ? Text(
                                    username.isNotEmpty
                                        ? username[0].toUpperCase()
                                        : '?',
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  )
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            username,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            _formatTime(_story.createdAt),
                            style: const TextStyle(color: Colors.white70),
                          ),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  left: 16,
                  right: 16,
                  bottom: 40,
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.white38),
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: Text(
                            'Reply to $username...',
                            style:
                                const TextStyle(color: Colors.white70),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      const Icon(
                        Icons.favorite_border,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 18),
                      const Icon(
                        Icons.send_rounded,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedia(String? url, String type) {
    if (url == null || url.isEmpty) {
      return const Center(
        child: Icon(Icons.broken_image, color: Colors.white30, size: 80),
      );
    }
    if (type == 'video') {
      final c = videoController;
      if (c == null || !c.value.isInitialized) {
        return const Center(child: CircularProgressIndicator());
      }
      return FittedBox(
        fit: BoxFit.contain,
        child: SizedBox(
          width: c.value.size.width,
          height: c.value.size.height,
          child: VideoPlayer(c),
        ),
      );
    }
    return Container(
      color: Colors.black,
      child: Center(
        child: Image.network(
          url,
          fit: BoxFit.contain,
          width: double.infinity,
          loadingBuilder: (_, child, progress) => progress == null
              ? child
              : const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                ),
          errorBuilder: (_, _, _) => const Center(
            child: Icon(Icons.broken_image, color: Colors.white30, size: 80),
          ),
        ),
      ),
    );
  }
}
