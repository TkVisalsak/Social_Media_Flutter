import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/short_model.dart';
import '../../../data/repositories/short_repository.dart';

class ReelItem extends StatefulWidget {
  final ShortModel short;
  final bool active;

  const ReelItem({
    super.key,
    required this.short,
    required this.active,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  VideoPlayerController? controller;
  bool _viewRecorded = false;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final url = widget.short.videoUrl;
    if (url.isEmpty) return;
    final c = VideoPlayerController.networkUrl(Uri.parse(url));
    controller = c;
    try {
      await c.initialize();
      if (!mounted) return;
      c.setLooping(true);
      if (widget.active) {
        c.play();
        _recordView();
      }
      setState(() {});
    } catch (_) {
      // Swallow video init errors — we show a placeholder.
    }
  }

  void _recordView() {
    if (_viewRecorded) return;
    _viewRecorded = true;
    if (Get.isRegistered<ShortRepository>()) {
      Get.find<ShortRepository>().recordView(widget.short.id);
    }
  }

  @override
  void didUpdateWidget(covariant ReelItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    final c = controller;
    if (c == null || !c.value.isInitialized) return;
    if (widget.active && !oldWidget.active) {
      c.play();
      _recordView();
    } else if (!widget.active && oldWidget.active) {
      c.pause();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final c = controller;
    final user = widget.short.user;
    final username =
        user.username ?? user.fullName ?? user.email.split('@').first;
    final caption = widget.short.caption ?? '';
    final hasProfile =
        user.profilePic != null && user.profilePic!.trim().isNotEmpty;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (c == null || !c.value.isInitialized) return;
        c.value.isPlaying ? c.pause() : c.play();
        setState(() {});
      },
      child: Container(
        color: Colors.black,
        child: Stack(
          children: [
            SizedBox.expand(
              child: c != null && c.value.isInitialized
                  ? Center(
                      child: AspectRatio(
                        aspectRatio: c.value.aspectRatio,
                        child: VideoPlayer(c),
                      ),
                    )
                  : const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
            ),
            if (c != null && c.value.isInitialized && !c.value.isPlaying)
              const Center(
                child: Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 80,
                ),
              ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.4),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 50,
              left: 16,
              right: 16,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Icon(Icons.add, color: Colors.white, size: 28),
                  Row(
                    children: [
                      Text(
                        'Reels',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(width: 16),
                      Text(
                        'Friends',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 20,
                        ),
                      ),
                    ],
                  ),
                  Icon(Icons.tune, color: Colors.white, size: 26),
                ],
              ),
            ),
            Positioned(
              right: 10,
              bottom: 120,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      if (Get.isRegistered<ShortRepository>()) {
                        Get.find<ShortRepository>()
                            .toggleLike(widget.short.id);
                      }
                    },
                    child: Icon(
                      widget.short.isLiked
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color: widget.short.isLiked ? Colors.red : Colors.white,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCount(widget.short.likeCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white,
                    size: 30,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _formatCount(widget.short.commentCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.repeat, color: Colors.white, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    _formatCount(widget.short.shareCount),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Icon(Icons.send, color: Colors.white, size: 30),
                  const SizedBox(height: 4),
                  Text(
                    _formatCount(widget.short.views),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.white24,
                    backgroundImage:
                        hasProfile ? NetworkImage(user.profilePic!) : null,
                    child: hasProfile
                        ? null
                        : const Icon(
                            Icons.person,
                            color: Colors.white,
                            size: 18,
                          ),
                  ),
                ],
              ),
            ),
            Positioned(
              left: 16,
              bottom: 40,
              right: 90,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: Colors.white24,
                        backgroundImage: hasProfile
                            ? NetworkImage(user.profilePic!)
                            : null,
                        child: hasProfile
                            ? null
                            : Text(
                                username.isNotEmpty
                                    ? username[0].toUpperCase()
                                    : '?',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        username,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Follow',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  if (caption.isNotEmpty)
                    Text(
                      caption,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black45,
                            borderRadius: BorderRadius.circular(30),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.music_note,
                                color: Colors.white,
                                size: 18,
                              ),
                              SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Original audio',
                                  style: TextStyle(color: Colors.white),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.remove_red_eye_outlined,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _formatCount(widget.short.views),
                              style:
                                  const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
