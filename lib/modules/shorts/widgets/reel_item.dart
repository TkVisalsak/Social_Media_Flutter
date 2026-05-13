import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../data/models/short_model.dart';
import '../../profile/views/other_profile_view.dart';
import '../controllers/shorts_controller.dart';
import 'reel_comments_sheet.dart';
import 'reel_share_sheet.dart';

class ReelItem extends StatefulWidget {
  final ShortModel short;
  final bool       isActive;

  const ReelItem({
    required super.key,           // key is required — parent passes ValueKey(short.id)
    required this.short,
    required this.isActive,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  VideoPlayerController? _ctrl;
  bool _showHeart   = false;
  bool _isFollowing = false;

  // ── Video lifecycle ───────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _initVideo();
  }

  void _initVideo() {
    final url = widget.short.videoUrl;
    if (url.isEmpty) return;

    _ctrl = VideoPlayerController.networkUrl(Uri.parse(url))
      ..addListener(_onVideoStateChange)
      ..initialize().then((_) {
          if (!mounted) return;
          _ctrl!.setLooping(true);
          if (widget.isActive) _ctrl!.play();
          setState(() {}); // first frame ready
        });
  }

  // Listener fires whenever VideoPlayerValue changes (playing, paused, buffering…)
  void _onVideoStateChange() {
    if (mounted) setState(() {});
  }

  @override
  void didUpdateWidget(ReelItem old) {
    super.didUpdateWidget(old);
    if (old.isActive != widget.isActive) {
      widget.isActive ? _ctrl?.play() : _ctrl?.pause();
    }
  }

  @override
  void dispose() {
    _ctrl?.removeListener(_onVideoStateChange);
    _ctrl?.dispose();
    super.dispose();
  }

  // ── Gesture handlers ─────────────────────────────────────────

  void _onTap() {
    if (_ctrl == null || !_ctrl!.value.isInitialized) return;
    // pause / play — listener will call setState when value actually changes
    _ctrl!.value.isPlaying ? _ctrl!.pause() : _ctrl!.play();
  }

  void _onDoubleTap() {
    // Like on double-tap only if not already liked
    final ctrl = Get.find<ShortsController>();
    final idx  = ctrl.shorts.indexWhere((s) => s.id == widget.short.id);
    if (idx >= 0 && !ctrl.shorts[idx].isLiked) {
      ctrl.toggleLike(widget.short.id);
    }
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  void _toggleLike() {
    Get.find<ShortsController>().toggleLike(widget.short.id);
  }

  void _openComments() {
    _ctrl?.pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReelCommentsSheet(commentCount: widget.short.commentCount),
    ).whenComplete(_resumeIfActive);
  }

  void _openShare() {
    _ctrl?.pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReelShareSheet(shortId: widget.short.id),
    ).whenComplete(_resumeIfActive);
  }

  void _openProfile() {
    _ctrl?.pause();
    final username   = widget.short.user.username ?? widget.short.user.fullName ?? 'user';
    final profilePic = widget.short.user.profilePic ?? '';
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => OtherProfileView(
        username: username,
        profileImage: profilePic,
        isNetworkImage: profilePic.startsWith('http'),
      )),
    ).whenComplete(_resumeIfActive);
  }

  void _resumeIfActive() {
    if (widget.isActive && mounted) _ctrl?.play();
  }

  // ── UI ────────────────────────────────────────────────────────

  static String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    final bottomPad  = MediaQuery.of(context).padding.bottom;
    final username   = widget.short.user.username ?? 'user';
    final profilePic = widget.short.user.profilePic;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _onTap,
      onDoubleTap: _onDoubleTap,
      child: SizedBox.expand(
        child: Stack(
          children: [
            // ── Video layer ──────────────────────────────────
            _buildVideoLayer(),

            // ── Dark gradient ────────────────────────────────
            Positioned.fill(
              child: IgnorePointer(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.45, 1.0],
                      colors: [Colors.transparent, Colors.black.withValues(alpha: 0.72)],
                    ),
                  ),
                ),
              ),
            ),

            // ── Pause indicator (updates via _onVideoStateChange) ──
            if (_ctrl != null &&
                _ctrl!.value.isInitialized &&
                !_ctrl!.value.isPlaying)
              const Center(
                child: IgnorePointer(
                  child: Icon(Icons.play_arrow_rounded,
                      color: Colors.white54, size: 72),
                ),
              ),

            // ── Double-tap heart burst ───────────────────────
            Center(
              child: IgnorePointer(
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: _showHeart ? 1.0 : 0.0,
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutBack,
                    scale: _showHeart ? 1.3 : 0.4,
                    child: const Icon(Icons.favorite_rounded,
                        color: Colors.white,
                        size: 120,
                        shadows: [Shadow(blurRadius: 40, color: Colors.white38)]),
                  ),
                ),
              ),
            ),

            // ── Right actions ────────────────────────────────
            Positioned(
              right: 10,
              bottom: bottomPad + 100,
              child: Column(
                children: [
                  // Avatar
                  GestureDetector(
                    onTap: _openProfile,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: CircleAvatar(
                        radius: 22,
                        backgroundColor: Colors.grey,
                        backgroundImage: profilePic != null && profilePic.isNotEmpty
                            ? NetworkImage(profilePic) as ImageProvider
                            : null,
                        child: profilePic == null || profilePic.isEmpty
                            ? Text(username.isNotEmpty ? username[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    color: Colors.white, fontWeight: FontWeight.bold))
                            : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),

                  // ── Like button (reactive via Obx) ───────────
                  Obx(() {
                    final ctrl = Get.find<ShortsController>();
                    final idx  = ctrl.shorts.indexWhere((s) => s.id == widget.short.id);
                    final s    = idx >= 0 ? ctrl.shorts[idx] : widget.short;
                    return _ActionBtn(
                      icon:    s.isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                      label:   _fmt(s.likeCount),
                      color:   s.isLiked ? const Color(0xFFFF4D6D) : Colors.white,
                      onTap:   _toggleLike,
                      animate: s.isLiked,
                    );
                  }),
                  const SizedBox(height: 20),

                  _ActionBtn(
                    icon:  Icons.chat_bubble_rounded,
                    label: _fmt(widget.short.commentCount),
                    onTap: _openComments,
                  ),
                  const SizedBox(height: 20),

                  _ActionBtn(
                    icon:    Icons.reply_rounded,
                    label:   _fmt(widget.short.shareCount),
                    onTap:   _openShare,
                    mirrorX: true,
                  ),
                  const SizedBox(height: 20),

                  _ActionBtn(icon: Icons.more_horiz_rounded, label: '', onTap: () {}),
                ],
              ),
            ),

            // ── Bottom info ──────────────────────────────────
            Positioned(
              left: 16,
              right: 80,
              bottom: bottomPad + 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _openProfile,
                        child: CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey,
                          backgroundImage: profilePic != null && profilePic.isNotEmpty
                              ? NetworkImage(profilePic) as ImageProvider
                              : null,
                          child: profilePic == null || profilePic.isEmpty
                              ? Text(username.isNotEmpty ? username[0].toUpperCase() : '?',
                                  style: const TextStyle(
                                      color: Colors.white, fontSize: 12))
                              : null,
                        ),
                      ),
                      const SizedBox(width: 10),
                      GestureDetector(
                        onTap: _openProfile,
                        child: Text(username,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15)),
                      ),
                      const SizedBox(width: 10),
                      if (!_isFollowing)
                        GestureDetector(
                          onTap: () => setState(() => _isFollowing = true),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 5),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('Follow',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ],
                  ),
                  if (widget.short.caption != null &&
                      widget.short.caption!.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(widget.short.caption!,
                        style: const TextStyle(
                            color: Colors.white, fontSize: 14, height: 1.4),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoLayer() {
    if (_ctrl == null || !_ctrl!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(
            color: Colors.white38, strokeWidth: 1.5),
      );
    }
    return SizedBox.expand(
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(
          width:  _ctrl!.value.size.width,
          height: _ctrl!.value.size.height,
          child:  VideoPlayer(_ctrl!),
        ),
      ),
    );
  }
}

// ─── Action button ────────────────────────────────────────────────────────────

class _ActionBtn extends StatelessWidget {
  final IconData     icon;
  final String       label;
  final Color        color;
  final VoidCallback onTap;
  final bool         animate;
  final bool         mirrorX;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color   = Colors.white,
    this.animate = false,
    this.mirrorX = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget ico = AnimatedScale(
      duration: const Duration(milliseconds: 200),
      scale: animate ? 1.25 : 1.0,
      child: Icon(icon, color: color, size: 30),
    );
    if (mirrorX) ico = Transform.scale(scaleX: -1, child: ico);
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          ico,
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ],
      ),
    );
  }
}
