import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/post_model.dart';
import '../../../shared/widgets/story_avatar.dart';
import '../../profile/views/other_profile_view.dart';
import '../../story/models/story_viewer_item.dart';
import '../../story/models/story_viewer_user.dart';
import '../../story/views/story_viewer_screen.dart';
import '../controllers/feed_controller.dart';
import '../screens/image_viewer_screen.dart';
import 'post_comments_sheet.dart';
import 'post_share_sheet.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isLiked    = false;
  bool _isReposted = false;

  @override
  void initState() {
    super.initState();
    _isLiked = widget.post.isLiked;
  }

  void _toggleLike() {
    setState(() => _isLiked = !_isLiked);
    Get.find<FeedController>().toggleLike(widget.post.id);
  }

  void _forceLike() {
    if (!_isLiked) _toggleLike();
  }

  void _toggleRepost() => setState(() => _isReposted = !_isReposted);

  void _openComments() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PostCommentsSheet(postId: widget.post.id),
  );

  void _openShare() => showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => PostShareSheet(postId: widget.post.id),
  );

  static String _timeAgo(DateTime t) {
    final diff = DateTime.now().difference(t);
    if (diff.inDays >= 1) return '${diff.inDays}D AGO';
    if (diff.inHours >= 1) return '${diff.inHours}H AGO';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}M AGO';
    return 'JUST NOW';
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final username = post.user.username ?? post.user.fullName ?? 'user';
    final profilePic = post.user.profilePic;
    final images = post.imageUrls;
    final caption = post.caption ?? '';
    final likeCount = post.likesCount + (_isLiked != post.isLiked ? (_isLiked ? 1 : -1) : 0);
    final timeAgo = _timeAgo(post.createdAt);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PostHeader(
            username: username,
            profilePic: profilePic,
            subtitle: post.location ?? '',
            hasStory: false,
            post: post,
          ),
          const SizedBox(height: 12),
          if (images.isNotEmpty)
            _PostImageSlider(images: images, onLike: _forceLike),
          const SizedBox(height: 14),
          _PostActions(
            isLiked: _isLiked,
            isReposted: _isReposted,
            onToggleLike: _toggleLike,
            onComment: _openComments,
            onRepost: _toggleRepost,
            onShare: _openShare,
          ),
          const SizedBox(height: 12),
          _PostCaption(
            username: username,
            caption: caption,
            likeCount: likeCount,
            commentCount: post.commentsCount,
            timeAgo: timeAgo,
            onViewComments: _openComments,
          ),
          const SizedBox(height: 18),
          Container(height: 1.2, color: AppColors.divider),
        ],
      ),
    );
  }
}

// ─── Post Header ─────────────────────────────────────────────────────────────

class _PostHeader extends StatelessWidget {
  final String username;
  final String? profilePic;
  final String subtitle;
  final bool hasStory;
  final PostModel post;

  const _PostHeader({
    required this.username,
    this.profilePic,
    required this.subtitle,
    required this.hasStory,
    required this.post,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        GestureDetector(
          onTap: () {
            if (!hasStory) return;
            final user = StoryViewerUser(
              username: username,
              profileImage: profilePic ?? '',
              isNetworkImage: true,
              stories: [],
            );
            Navigator.push(context, MaterialPageRoute(
              builder: (_) => StoryViewerScreen(users: [user], initialUserIndex: 0),
            ));
          },
          child: StoryAvatar(
            imagePath: profilePic,
            isNetworkImage: profilePic?.startsWith('http') ?? false,
            username: username,
            radius: 20,
            hasRing: hasStory,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.push(context, MaterialPageRoute(
              builder: (_) => OtherProfileView(
                username: username,
                profileImage: profilePic ?? '',
                isNetworkImage: profilePic?.startsWith('http') ?? false,
              ),
            )),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(username, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                if (subtitle.isNotEmpty)
                  Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),
        ),
        IconButton(onPressed: () {}, icon: const Icon(Icons.more_horiz, size: 22)),
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
  final PageController _pageController = PageController();
  int  _currentPage = 0;
  bool _showHeart   = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onDoubleTap() {
    widget.onLike();
    setState(() => _showHeart = true);
    Future.delayed(const Duration(milliseconds: 700), () {
      if (mounted) setState(() => _showHeart = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(26),
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            height: 320,
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.images.length,
              onPageChanged: (i) => setState(() => _currentPage = i),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onDoubleTap: _onDoubleTap,
                  onTap: () => Navigator.push(context, MaterialPageRoute(
                    builder: (_) => ImageViewerScreen(
                      images: widget.images,
                      initialIndex: index,
                    ),
                  )),
                  child: Container(
                    color: Colors.black,
                    child: Image.network(
                      widget.images[index],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      loadingBuilder: (_, child, progress) =>
                          progress == null ? child : const Center(child: CircularProgressIndicator(color: Colors.white38, strokeWidth: 1.5)),
                      errorBuilder: (_, _, _) => const Center(child: Icon(Icons.broken_image, color: Colors.white30, size: 60)),
                    ),
                  ),
                );
              },
            ),
          ),
          if (widget.images.length > 1)
            Positioned(top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: Colors.black38, borderRadius: BorderRadius.circular(20)),
                child: Text('${_currentPage + 1} / ${widget.images.length}',
                    style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
              )),
          if (widget.images.length > 1)
            Positioned(bottom: 14,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(widget.images.length, (i) {
                  final active = i == _currentPage;
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
              )),
          IgnorePointer(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 250),
              opacity: _showHeart ? 1 : 0,
              child: AnimatedScale(
                duration: const Duration(milliseconds: 250),
                scale: _showHeart ? 1 : 0.6,
                child: const Icon(Icons.favorite, color: Colors.white, size: 110),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Actions row ─────────────────────────────────────────────────────────────

class _PostActions extends StatelessWidget {
  final bool isLiked;
  final bool isReposted;
  final VoidCallback onToggleLike;
  final VoidCallback onComment;
  final VoidCallback onRepost;
  final VoidCallback onShare;

  const _PostActions({
    required this.isLiked,
    required this.isReposted,
    required this.onToggleLike,
    required this.onComment,
    required this.onRepost,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Row(
        children: [
          GestureDetector(
            onTap: onToggleLike,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 200),
              scale: isLiked ? 1.15 : 1,
              child: Icon(
                isLiked ? Icons.favorite : Icons.favorite_outline,
                size: 26,
                color: isLiked ? AppColors.like : Colors.black,
              ),
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(onTap: onComment, child: const _ActionIcon(Icons.chat_bubble_outline_rounded)),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: onRepost,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 180),
              scale: isReposted ? 1.15 : 1.0,
              child: Icon(Icons.repeat_rounded, size: 26,
                  color: isReposted ? AppColors.repost : Colors.black),
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(onTap: onShare, child: const _ActionIcon(Icons.reply_rounded)),
          const Spacer(),
          const _ActionIcon(Icons.bookmark_outline),
        ],
      ),
    );
  }
}

// ─── Caption ─────────────────────────────────────────────────────────────────

class _PostCaption extends StatelessWidget {
  final String username;
  final String caption;
  final int likeCount;
  final int commentCount;
  final String timeAgo;
  final VoidCallback onViewComments;

  const _PostCaption({
    required this.username,
    required this.caption,
    required this.likeCount,
    required this.commentCount,
    required this.timeAgo,
    required this.onViewComments,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$likeCount likes', style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        if (caption.isNotEmpty)
          RichText(
            text: TextSpan(
              style: const TextStyle(color: Colors.black, fontSize: 14, height: 1.7),
              children: [
                TextSpan(text: '$username ', style: const TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: caption),
              ],
            ),
          ),
        const SizedBox(height: 10),
        GestureDetector(
          onTap: onViewComments,
          child: Text('View all $commentCount comments',
              style: TextStyle(color: Colors.grey.shade600)),
        ),
        const SizedBox(height: 6),
        Text(timeAgo,
            style: TextStyle(color: Colors.grey.shade500, fontSize: 11, letterSpacing: 1)),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  const _ActionIcon(this.icon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Icon(icon, size: 25, color: Colors.black),
    );
  }
}
