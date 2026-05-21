import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:video_player/video_player.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/services/repost_store.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/repost_model.dart';
import '../../../data/models/short_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/repost_repository.dart';
import '../../../shared/widgets/social_action_buttons.dart';
import '../controllers/shorts_controller.dart';
import 'reel_comments_sheet.dart';
import 'reel_share_sheet.dart';

class ReelItem extends StatefulWidget {
  final ShortModel short;
  final bool       isActive;
  /// Height of the bottom nav bar to offset content above. Pass 0 when there
  /// is no bottom nav bar (e.g. UserShortsPlayer).
  final double     navBarH;

  const ReelItem({
    required super.key,           // key is required — parent passes ValueKey(short.id)
    required this.short,
    required this.isActive,
    this.navBarH = 65.0,
  });

  @override
  State<ReelItem> createState() => _ReelItemState();
}

class _ReelItemState extends State<ReelItem> {
  VideoPlayerController? _ctrl;
  bool       _showHeart     = false;
  final _isFollowing        = false.obs;
  bool       _followLoading = false;
  bool       _isReposted    = false;
  String?    _repostId;
  bool       _repostLoading = false;
  int        _repostCount   = 0; // seeded from model in initState
  bool       _isOwnVideo    = false;
  Timer?  _tapTimer;
  Worker? _visibilityWorker;
  Worker? _repostWorker;

  // ── Video lifecycle ───────────────────────────────────────────

  @override
  void initState() {
    super.initState();
    _repostCount = widget.short.repostCount;
    _initVideo();
    _initRepostState();
    _visibilityWorker = ever(
      Get.find<ShortsController>().isTabVisible,
      (bool visible) {
        if (!mounted || _ctrl == null) return;
        if (visible && widget.isActive) {
          _ctrl!.play();
        } else if (!visible) {
          _ctrl!.pause();
        }
      },
    );
    _loadFollowStatus();
    _detectOwnVideo();
  }

  void _initRepostState() {
    _syncFromStore();
    if (Get.isRegistered<RepostStore>()) {
      _repostWorker = ever(Get.find<RepostStore>().version, (_) {
        if (mounted && !_repostLoading) _syncFromStore();
      });
    }
  }

  void _syncFromStore() {
    if (!Get.isRegistered<RepostStore>()) return;
    final store = Get.find<RepostStore>();
    setState(() {
      _isReposted = store.isReposted(widget.short.id);
      _repostId   = store.repostDocId(widget.short.id);
    });
  }

  void _initVideo() {
    final url = widget.short.videoUrl;
    if (url.isEmpty) return;

    _ctrl = VideoPlayerController.networkUrl(Uri.parse(url))
      ..addListener(_onVideoStateChange)
      ..initialize().then((_) {
          if (!mounted) return;
          _ctrl!.setLooping(true);
          if (widget.isActive && Get.find<ShortsController>().isTabVisible.value) {
            _ctrl!.play();
          }
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
    _visibilityWorker?.dispose();
    _repostWorker?.dispose();
    _tapTimer?.cancel();
    _ctrl?.removeListener(_onVideoStateChange);
    _ctrl?.dispose();
    super.dispose();
  }

  // ── Gesture handlers ─────────────────────────────────────────

  // Single tap handling is delayed by Flutter 300ms when onDoubleTap is also
  // registered. Instead we manage the double-tap detection ourselves so single
  // tap (pause/play) fires after only 220ms and double tap fires instantly on
  // the second tap without any delay.
  void _handleTap() {
    if (_tapTimer != null) {
      _tapTimer!.cancel();
      _tapTimer = null;
      _onDoubleTap();
      return;
    }
    _tapTimer = Timer(const Duration(milliseconds: 220), () {
      _tapTimer = null;
      _onSingleTap();
    });
  }

  void _onSingleTap() {
    if (_ctrl == null || !_ctrl!.value.isInitialized) return;
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

  void _toggleRepost() => _doToggleRepost();

  Future<void> _doToggleRepost() async {
    if (_repostLoading) return;
    setState(() => _repostLoading = true);

    if (_isReposted) {
      if (_repostId != null) {
        final res = await Get.find<RepostRepository>().deleteRepost(_repostId!);
        if (res.success) {
          if (Get.isRegistered<RepostStore>()) {
            Get.find<RepostStore>().remove(widget.short.id);
          }
          setState(() {
            _isReposted = false;
            _repostId   = null;
            _repostCount = (_repostCount - 1).clamp(0, 999999);
          });
        }
      }
    } else {
      final res = await Get.find<RepostRepository>().repost(
        contentId: widget.short.id,
        contentType: RepostContentType.short,
      );
      if (res.success && res.data != null) {
        if (Get.isRegistered<RepostStore>()) {
          Get.find<RepostStore>().add(widget.short.id, res.data!.id);
        }
        setState(() {
          _isReposted  = true;
          _repostId    = res.data!.id;
          _repostCount = _repostCount + 1;
        });
      } else {
        final err = res.error ?? '';
        if (err.toLowerCase().contains('already')) {
          setState(() => _isReposted = true);
        } else if (err.isNotEmpty) {
          Get.snackbar('Repost failed', err, snackPosition: SnackPosition.BOTTOM);
        }
      }
    }

    setState(() => _repostLoading = false);
  }

  void _openComments() {
    _ctrl?.pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReelCommentsSheet(
        shortId: widget.short.id,
        commentCount: widget.short.commentCount,
      ),
    ).whenComplete(_resumeIfActive);
  }

  void _openShare() {
    _ctrl?.pause();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ReelShareSheet(shortId: widget.short.id),
    ).then((_) {
      // Increment share count whenever the sheet is dismissed (user interacted)
      Get.find<ShortsController>().incrementShareCount(widget.short.id);
    }).whenComplete(_resumeIfActive);
  }

  void _openMore() {
    _ctrl?.pause();
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            if (_isOwnVideo) ...[
              ListTile(
                leading: const Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: const Text('Delete reel', style: TextStyle(color: Colors.red)),
                onTap: () async {
                  Navigator.pop(context);
                  final confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Delete Reel?'),
                      content: const Text('This cannot be undone.'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: const Text('Delete', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                  if (confirmed == true) {
                    await Get.find<ShortsController>().deleteShort(widget.short.id);
                  }
                },
              ),
            ],
            ListTile(
              leading: const Icon(Icons.not_interested_rounded),
              title: const Text('Not Interested'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Got it', 'You will see fewer reels like this.',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2));
              },
            ),
            ListTile(
              leading: const Icon(Icons.flag_rounded),
              title: const Text('Report'),
              onTap: () {
                Navigator.pop(context);
                Get.snackbar('Reported', 'Thanks for letting us know.',
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 2));
              },
            ),
            ListTile(
              leading: const Icon(Icons.block_rounded),
              title: const Text('Block user'),
              onTap: () => Navigator.pop(context),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    ).whenComplete(_resumeIfActive);
  }

  Future<void> _detectOwnVideo() async {
    final me = await LocalStorage.user;
    if (mounted) setState(() => _isOwnVideo = me?.id == widget.short.user.id);
  }

  Future<void> _loadFollowStatus() async {
    final userId = widget.short.user.id;
    if (userId.isEmpty) return;
    final ctrl = Get.find<ShortsController>();
    final following = await ctrl.getFollowStatus(userId);
    if (mounted) _isFollowing.value = following;
  }

  Future<void> _toggleFollow() async {
    if (_followLoading) return;
    final userId = widget.short.user.id;
    if (userId.isEmpty) return;
    setState(() => _followLoading = true);
    final wasFollowing = _isFollowing.value;
    _isFollowing.value = !wasFollowing;
    final ctrl = Get.find<ShortsController>();
    final ok = wasFollowing
        ? await ctrl.unfollowUser(userId)
        : await ctrl.followUser(userId);
    if (!ok) _isFollowing.value = wasFollowing;
    setState(() => _followLoading = false);
  }

  void _openProfile() {
    _ctrl?.pause();
    if (_isOwnVideo) {
      Get.until((route) => route.isFirst);
    } else {
      Get.toNamed(AppRoutes.OTHER_PROFILE, arguments: widget.short.user)
          ?.whenComplete(_resumeIfActive);
    }
  }

  void _resumeIfActive() {
    if (widget.isActive && mounted) _ctrl?.play();
  }

  // ── UI ────────────────────────────────────────────────────────

  static String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    final bottomPad     = MediaQuery.of(context).padding.bottom;
    final contentBottom = bottomPad + widget.navBarH + 4;
    final username      = widget.short.user.username ?? widget.short.user.fullName ?? 'user';
    final profilePic    = widget.short.user.profilePic;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _handleTap,
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
              bottom: contentBottom,
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
                  const SizedBox(height: 8),

                  // ── Like button ───────────────────────────────
                  Obx(() {
                    final ctrl = Get.find<ShortsController>();
                    final idx  = ctrl.shorts.indexWhere((s) => s.id == widget.short.id);
                    final s    = idx >= 0 ? ctrl.shorts[idx] : widget.short;
                    return LikeButton(
                      isLiked: s.isLiked,
                      likeCount: s.likeCount,
                      onTap: (_) => _toggleLike(),
                      size: 26,
                      likedColor: const Color(0xFFFF4D6D),
                      unlikedColor: Colors.white,
                      axis: Axis.vertical,
                    );
                  }),
                  const SizedBox(height: 8),

                  // ── Comment button ────────────────────────────
                  Obx(() {
                    final ctrl = Get.find<ShortsController>();
                    final idx  = ctrl.shorts.indexWhere((s) => s.id == widget.short.id);
                    final s    = idx >= 0 ? ctrl.shorts[idx] : widget.short;
                    return _ActionBtn(
                      icon:  Icons.chat_bubble_rounded,
                      label: _fmt(s.commentCount),
                      onTap: _openComments,
                    );
                  }),
                  const SizedBox(height: 8),

                  // ── Repost button ─────────────────────────────
                  IgnorePointer(
                    ignoring: _repostLoading,
                    child: RepostButton(
                      isReposted: _isReposted,
                      repostCount: _repostCount,
                      onTap: (_) => _toggleRepost(),
                      size: 26,
                      repostedColor: AppColors.repost,
                      unrepostedColor: Colors.white,
                      axis: Axis.vertical,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // ── Share button ──────────────────────────────
                  Obx(() {
                    final ctrl = Get.find<ShortsController>();
                    final idx  = ctrl.shorts.indexWhere((s) => s.id == widget.short.id);
                    final s    = idx >= 0 ? ctrl.shorts[idx] : widget.short;
                    return _ActionBtn(
                      icon:    Icons.reply_rounded,
                      label:   _fmt(s.shareCount),
                      onTap:   _openShare,
                      mirrorX: true,
                    );
                  }),
                  const SizedBox(height: 8),

                  _ActionBtn(icon: Icons.more_horiz_rounded, label: '', onTap: _openMore),
                ],
              ),
            ),

            // ── Bottom info ──────────────────────────────────
            Positioned(
              left: 16,
              right: 80,
              bottom: contentBottom,
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
                      if (!_isOwnVideo) ...[
                        const SizedBox(width: 8),
                        Obx(() => IgnorePointer(
                          ignoring: _followLoading,
                          child: FollowButton(
                            isFollowing: _isFollowing.value,
                            onTap: (_) => _toggleFollow(),
                            brandColor: Colors.transparent,
                            unfollowedBorderColor: Colors.white,
                            followedBgColor: Colors.white.withValues(alpha: 0.25),
                            followedFgColor: Colors.white,
                            followedBorderColor: Colors.white,
                            height: 30,
                          ),
                        )),
                      ],
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
    final thumb = widget.short.thumbnailUrl;

    if (_ctrl == null || !_ctrl!.value.isInitialized) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (thumb != null && thumb.isNotEmpty)
            Image.network(
              thumb,
              fit: BoxFit.cover,
              errorBuilder: (context, err, stack) => const ColoredBox(color: Colors.black),
            )
          else
            const ColoredBox(color: Colors.black),
          const Center(
            child: CircularProgressIndicator(
                color: Colors.white38, strokeWidth: 1.5),
          ),
        ],
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
  final VoidCallback onTap;
  final bool         mirrorX;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.mirrorX = false,
  });

  @override
  Widget build(BuildContext context) {
    Widget ico = Icon(icon, color: Colors.white, size: 30);
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
