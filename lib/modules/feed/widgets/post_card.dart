import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/repost_model.dart';
import '../../../data/repositories/repost_repository.dart';
import '../../../shared/widgets/social_action_buttons.dart';
import '../../../shared/widgets/story_avatar.dart';
import '../controllers/feed_controller.dart';
import '../screens/image_viewer_screen.dart';
import 'post_comments_sheet.dart';
import 'post_share_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({required super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool    _isReposted     = false;
  String? _repostId;        // server-side repost document ID, needed to delete
  bool    _repostLoading  = false;

  void _toggleLike() =>
      Get.find<FeedController>().toggleLike(widget.post.id);

  void _forceLike() {
    if (!widget.post.isLiked) _toggleLike();
  }

  // Fire-and-forget wrapper so the VoidCallback signature is satisfied.
  void _toggleRepost() => _doToggleRepost();

  Future<void> _doToggleRepost() async {
    if (_repostLoading) return;
    setState(() => _repostLoading = true);

    if (_isReposted) {
      await _unrepost();
    } else {
      await _repost();
    }

    setState(() => _repostLoading = false);
  }

  Future<void> _repost() async {
    final res = await Get.find<RepostRepository>().repost(
      contentId: widget.post.id,
      contentType: RepostContentType.feed,
    );

    if (res.success && res.data != null) {
      setState(() {
        _isReposted = true;
        _repostId   = res.data!.id;
      });
      Get.find<FeedController>().toggleRepost(widget.post.id, reposted: true);
    } else {
      final err = res.error ?? '';
      if (err.toLowerCase().contains('already')) {
        // User already reposted — sync UI silently without touching count.
        setState(() => _isReposted = true);
      } else {
        Get.snackbar('Repost failed', err.isNotEmpty ? err : 'Try again',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  Future<void> _unrepost() async {
    if (_repostId == null) return;

    final res = await Get.find<RepostRepository>().deleteRepost(_repostId!);

    if (res.success) {
      setState(() {
        _isReposted = false;
        _repostId   = null;
      });
      Get.find<FeedController>().toggleRepost(widget.post.id, reposted: false);
    } else {
      Get.snackbar('Error', res.error ?? 'Failed to remove repost',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void _openComments() => showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => PostCommentsSheet(
          postId: widget.post.id,
          onCommented: () =>
              Get.find<FeedController>().incrementCommentCount(widget.post.id),
        ),
      );

  void _openShare() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PostShareSheet(
        postId: widget.post.id,
        onShared: () =>
            Get.find<FeedController>().incrementShareCount(widget.post.id),
      ),
    );
  }

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays}D AGO';
    if (d.inHours >= 1) return '${d.inHours}H AGO';
    if (d.inMinutes >= 1) return '${d.inMinutes}M AGO';
    return 'JUST NOW';
  }

  @override
  Widget build(BuildContext context) {
    final post       = widget.post;
    final username   = post.user.username ?? post.user.fullName ?? 'user';
    final profilePic = post.user.profilePic;
    final images     = post.imageUrls;
    final caption    = post.caption ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: _PostHeader(username: username, profilePic: profilePic,
              subtitle: post.location ?? '', post: post),
        ),
        const SizedBox(height: 12),
        if (images.isNotEmpty)
          _PostImageSlider(images: images, onLike: _forceLike),
        const SizedBox(height: 10),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PostActions(
                postId: widget.post.id,
                fallbackPost: widget.post,
                isReposted: _isReposted,
                isRepostLoading: _repostLoading,
                onToggleLike: _toggleLike,
                onComment: _openComments,
                onRepost: _toggleRepost,
                onShare: _openShare,
              ),
              const SizedBox(height: 12),
              _PostCaption(
                postId: widget.post.id,
                fallbackPost: widget.post,
                username: username,
                caption: caption,
                timeAgo: _timeAgo(post.createdAt),
                onViewComments: _openComments,
              ),
              const SizedBox(height: 14),
            ],
          ),
        ),
        Container(height: 1.2, color: AppColors.divider),
      ],
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _PostHeader extends StatelessWidget {
  final String   username;
  final String?  profilePic;
  final String   subtitle;
  final PostModel post;

  const _PostHeader({
    required this.username,
    this.profilePic,
    required this.subtitle,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {},
          child: StoryAvatar(
            imagePath: profilePic,
            isNetworkImage: profilePic?.startsWith('http') ?? false,
            username: username,
            radius: 20,
            hasRing: false,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => Get.toNamed(AppRoutes.OTHER_PROFILE, arguments: post.user),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 15)),
                if (subtitle.isNotEmpty)
                  Text(subtitle,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ),
        IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_horiz, size: 22)),
      ],
    );
  }
}

// ─── Image slider ─────────────────────────────────────────────────────────────

class _PostImageSlider extends StatefulWidget {
  final List<String> images;
  final VoidCallback onLike;
  const _PostImageSlider({required this.images, required this.onLike});

  @override
  State<_PostImageSlider> createState() => _PostImageSliderState();
}

class _PostImageSliderState extends State<_PostImageSlider> {
  final _page  = PageController();
  int  _cur    = 0;
  bool _heart  = false;

  @override
  void dispose() {
    _page.dispose();
    super.dispose();
  }

  void _doubleTap() {
    widget.onLike();
    setState(() => _heart = true);
    Future.delayed(const Duration(milliseconds: 700),
        () { if (mounted) setState(() => _heart = false); });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 320,
            child: PageView.builder(
              controller: _page,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _cur = i),
              itemBuilder: (context, i) => GestureDetector(
                onDoubleTap: _doubleTap,
                onTap: () => Navigator.push(context, MaterialPageRoute(
                  builder: (_) => ImageViewerScreen(
                      images: widget.images, initialIndex: i),
                )),
                child: Container(
                  color: Colors.black,
                  child: Image.network(widget.images[i],
                    fit: BoxFit.cover,
                    width: double.infinity,
                    loadingBuilder: (_, child, p) => p == null ? child
                        : const Center(child: CircularProgressIndicator(
                            color: Colors.white38, strokeWidth: 1.5)),
                    errorBuilder: (_, _, _) => const Center(
                        child: Icon(Icons.broken_image,
                            color: Colors.white30, size: 60)),
                  ),
                ),
              ),
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                    color: Colors.black38,
                    borderRadius: BorderRadius.circular(20)),
                child: Text('${_cur + 1} / ${widget.images.length}',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600)),
              ),
            ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 14,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.images.length, (i) {
                  final active = i == _cur;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 3),
                    width: active ? 18 : 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: active ? Colors.white : Colors.white54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                  );
                }),
              ),
            ),
          IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _heart ? 1 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: _heart ? 1 : 0.6,
                child: const Icon(Icons.favorite,
                    color: Colors.white, size: 110),
              ),
            ),
          ),
        ],
    );
  }
}

// ─── Actions row ─────────────────────────────────────────────────────────────

class _PostActions extends StatelessWidget {
  final String       postId;
  final PostModel    fallbackPost;
  final bool         isReposted;
  final bool         isRepostLoading;
  final VoidCallback onToggleLike;
  final VoidCallback onComment;
  final VoidCallback onRepost;
  final VoidCallback onShare;

  const _PostActions({
    required this.postId,
    required this.fallbackPost,
    required this.isReposted,
    required this.isRepostLoading,
    required this.onToggleLike,
    required this.onComment,
    required this.onRepost,
    required this.onShare,
  });

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000)    return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  PostModel _live(FeedController ctrl) {
    final idx = ctrl.posts.indexWhere((p) => p.id == postId);
    return idx >= 0 ? ctrl.posts[idx] : fallbackPost;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          // ── Like ──────────────────────────────────────────
          Obx(() {
            final p = _live(Get.find<FeedController>());
            return LikeButton(
              isLiked: p.isLiked,
              likeCount: p.likesCount,
              onTap: (_) => onToggleLike(),
              size: 26,
              likedColor: AppColors.like,
              unlikedColor: Colors.black,
            );
          }),
          const SizedBox(width: 8),
          // ── Comment ───────────────────────────────────────
          Obx(() {
            final p = _live(Get.find<FeedController>());
            return _Btn(
              icon: Icons.chat_bubble_outline_rounded,
              label: _fmt(p.commentsCount),
              onTap: onComment,
            );
          }),
          const SizedBox(width: 8),
          // ── Repost ────────────────────────────────────────
          Obx(() {
            final p = _live(Get.find<FeedController>());
            return IgnorePointer(
              ignoring: isRepostLoading,
              child: RepostButton(
                isReposted: isReposted,
                repostCount: p.repostsCount,
                onTap: (_) => onRepost(),
                size: 22,
                repostedColor: AppColors.repost,
                unrepostedColor: Colors.black87,
              ),
            );
          }),
          const SizedBox(width: 8),
          // ── Share ─────────────────────────────────────────
          Obx(() {
            final p = _live(Get.find<FeedController>());
            return _Btn(
              icon: Icons.reply_rounded,
              label: _fmt(p.sharesCount),
              onTap: onShare,
            );
          }),
          const Spacer(),
          // ── Save ──────────────────────────────────────────
          Obx(() {
            final p = _live(Get.find<FeedController>());
            return GestureDetector(
              onTap: () => Get.find<FeedController>().toggleSave(postId),
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Icon(
                  p.isSaved ? Icons.bookmark : Icons.bookmark_outline,
                  size: 25,
                  color: p.isSaved ? const Color(0xFF3797F0) : Colors.black,
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String   label;
  final VoidCallback onTap;

  const _Btn({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: Colors.black),
          if (label.isNotEmpty) ...[
            const SizedBox(width: 5),
            Text(label,
                style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                    fontFamily: 'Roboto')),
          ],
        ],
      ),
    );
  }
}

// ─── Caption ─────────────────────────────────────────────────────────────────

class _PostCaption extends StatelessWidget {
  final String       postId;
  final PostModel    fallbackPost;
  final String       username;
  final String       caption;
  final String       timeAgo;
  final VoidCallback onViewComments;

  const _PostCaption({
    required this.postId,
    required this.fallbackPost,
    required this.username,
    required this.caption,
    required this.timeAgo,
    required this.onViewComments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (caption.isNotEmpty)
          RichText(
            text: TextSpan(
              style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 1.7,
                  fontFamily: 'Roboto'),
              children: [
                TextSpan(
                    text: '$username ',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: caption),
              ],
            ),
          ),
        Obx(() {
          final ctrl = Get.find<FeedController>();
          final idx  = ctrl.posts.indexWhere((p) => p.id == postId);
          final count = idx >= 0 ? ctrl.posts[idx].commentsCount : fallbackPost.commentsCount;
          if (count <= 0) return const SizedBox.shrink();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              GestureDetector(
                onTap: onViewComments,
                child: Text('View all $count comments',
                    style: TextStyle(color: Colors.grey.shade600)),
              ),
            ],
          );
        }),
        const SizedBox(height: 6),
        Text(timeAgo,
            style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 11,
                letterSpacing: 1)),
      ],
    );
  }
}
