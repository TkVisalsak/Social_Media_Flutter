import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/post_model.dart';
import '../controllers/feed_controller.dart';
import '../screens/image_viewer_screen.dart';

class PostCard extends StatefulWidget {
  final PostModel post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  int currentPage = 0;
  bool showHeart = false;
  final PageController pageController = PageController();

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inDays >= 1) return '${diff.inDays}D AGO';
    if (diff.inHours >= 1) return '${diff.inHours}H AGO';
    if (diff.inMinutes >= 1) return '${diff.inMinutes}M AGO';
    return 'JUST NOW';
  }

  String _formatLikes(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final user = post.user;
    final username =
        user.username ?? user.fullName ?? user.email.split('@').first;
    final subtitle = post.location ?? '';
    final caption = (post.caption ?? '').trim();
    final imageUrls = post.imageUrls;
    final hasMedia = imageUrls.isNotEmpty;
    final profilePic = user.profilePic;
    final hasProfilePic = profilePic != null && profilePic.trim().isNotEmpty;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [Color(0xFFFF5F6D), Color(0xFFFFC371)],
                  ),
                ),
                child: CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage:
                      hasProfilePic ? NetworkImage(profilePic) : null,
                  child: hasProfilePic
                      ? null
                      : Text(
                          username.isNotEmpty
                              ? username[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      username,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    if (subtitle.isNotEmpty)
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.more_horiz, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Image carousel
          if (hasMedia)
            ClipRRect(
              borderRadius: BorderRadius.circular(26),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    height: 320,
                    child: PageView.builder(
                      controller: pageController,
                      itemCount: imageUrls.length,
                      onPageChanged: (i) => setState(() => currentPage = i),
                      itemBuilder: (context, index) {
                        final url = imageUrls[index];
                        return GestureDetector(
                          onDoubleTap: () {
                            if (!post.isLiked) {
                              Get.find<FeedController>().toggleLike(post.id);
                            }
                            setState(() => showHeart = true);
                            Future.delayed(
                              const Duration(milliseconds: 700),
                              () {
                                if (mounted) {
                                  setState(() => showHeart = false);
                                }
                              },
                            );
                          },
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ImageViewerScreen(
                                  images: imageUrls,
                                  initialIndex: index,
                                ),
                              ),
                            );
                          },
                          child: Container(
                            color: Colors.black,
                            child: Center(
                              child: Image.network(
                                url,
                                fit: BoxFit.contain,
                                width: double.infinity,
                                loadingBuilder: (_, child, progress) =>
                                    progress == null
                                        ? child
                                        : const Center(
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                            ),
                                          ),
                                errorBuilder: (_, _, _) => const Center(
                                  child: Icon(
                                    Icons.broken_image,
                                    color: Colors.white30,
                                    size: 64,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  if (imageUrls.length > 1)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black38,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${currentPage + 1}/${imageUrls.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  if (imageUrls.length > 1)
                    Positioned(
                      bottom: 14,
                      child: Row(
                        children: List.generate(imageUrls.length, (index) {
                          final active = currentPage == index;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 3),
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
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 250),
                    opacity: showHeart ? 1 : 0,
                    child: AnimatedScale(
                      duration: const Duration(milliseconds: 250),
                      scale: showHeart ? 1 : 0.6,
                      child: const Icon(
                        Icons.favorite,
                        color: Colors.white,
                        size: 110,
                      ),
                    ),
                  ),
                ],
              ),
            ),

          if (!hasMedia && caption.isNotEmpty)
            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              decoration: BoxDecoration(
                color: const Color(0xFFF5F6F7),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFE6E7EA)),
              ),
              child: Text(
                caption,
                style: const TextStyle(
                  fontSize: 18,
                  height: 1.35,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ),

          const SizedBox(height: 14),

          // Action row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () =>
                      Get.find<FeedController>().toggleLike(post.id),
                  child: AnimatedScale(
                    duration: const Duration(milliseconds: 200),
                    scale: post.isLiked ? 1.15 : 1,
                    child: Icon(
                      post.isLiked
                          ? Icons.favorite
                          : Icons.favorite_outline,
                      size: 26,
                      color: post.isLiked ? Colors.red : Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () =>
                      Get.find<FeedController>().openPostDetail(post),
                  child: const Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 25,
                    ),
                  ),
                ),
                const SizedBox(width: 20),
                const Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.reply_rounded, size: 25),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      Get.find<FeedController>().toggleSave(post.id),
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Icon(
                      post.isSaved
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      size: 25,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          if (post.likesCount > 0)
            Text(
              '${_formatLikes(post.likesCount)} likes',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),

          if (caption.isNotEmpty && hasMedia) ...[
            const SizedBox(height: 8),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 14,
                  height: 1.7,
                ),
                children: [
                  TextSpan(
                    text: '$username ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(text: caption),
                ],
              ),
            ),
          ],

          const SizedBox(height: 10),

          if (post.commentsCount > 0)
            GestureDetector(
              onTap: () => Get.find<FeedController>().openPostDetail(post),
              child: Text(
                'view all ${post.commentsCount} comments',
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ),

          const SizedBox(height: 6),
          Text(
            _formatTimeAgo(post.createdAt),
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              letterSpacing: 1,
            ),
          ),

          const SizedBox(height: 18),
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: double.infinity,
            height: 1.2,
            color: const Color(0xFFE5E5E5),
          ),
        ],
      ),
    );
  }
}
