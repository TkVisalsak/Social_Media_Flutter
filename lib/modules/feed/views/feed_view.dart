import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/feed_controller.dart';
import '../../../app/routes/app_routes.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.add, color: Colors.black),
          onPressed: () => controller.openPlusMenu(context),
        ),
        title: const Text(
          'Social app',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
            fontFamily: 'Georgia',
          ),
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.replay_outlined, color: Colors.black),
                onPressed: () => Get.toNamed(AppRoutes.DIRECT),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.fetchFeed(refresh: true),
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.pixels >=
                notification.metrics.maxScrollExtent - 200) {
              controller.fetchFeed();
            }
            return false;
          },
          child: CustomScrollView(
            slivers: [
              // Stories bar
              SliverToBoxAdapter(
                child: _StoriesBar(),
              ),
              // Posts
              Obx(() {
                if (controller.isLoading.value && controller.posts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                return SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) {
                      if (i == controller.posts.length) {
                        if (!controller.hasMore.value) return const SizedBox();
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }
                      return _PostCard(post: controller.posts[i]);
                    },
                    childCount: controller.posts.length + 1,
                  ),
                );
              }),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const _BottomNav(),
    );
  }
}

// ─── Stories Bar ────────────────────────────────────

class _StoriesBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final stories = [
      {'name': 'Your story', 'isOwn': true},
      {'name': 'leo.messi', 'isOwn': false},
      {'name': 'cuifenn', 'isOwn': false},
      {'name': '_.brainn', 'isOwn': false},
      {'name': 'm.a.a.m', 'isOwn': false},
    ];

    return SizedBox(
      height: 96,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: stories.length,
        itemBuilder: (_, i) {
          final s = stories[i];
          final isOwn = s['isOwn'] as bool;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Stack(
                  children: [
                    Container(
                      width: 58,
                      height: 58,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: isOwn
                            ? null
                            : const LinearGradient(
                                colors: [Color(0xFFE91E8C), Color(0xFF6C63FF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                        color: isOwn ? Colors.grey[200] : null,
                      ),
                      padding: const EdgeInsets.all(2.5),
                      child: CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        child: Icon(Icons.person,
                            color: Colors.grey[600], size: 26),
                      ),
                    ),
                    if (isOwn)
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: Color(0xFF4361EE),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.add,
                              color: Colors.white, size: 14),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  s['name'] as String,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.black87),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ─── Post Card ──────────────────────────────────────

class _PostCard extends StatelessWidget {
  final dynamic post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final user = post.user;
    final username = (() {
      final candidates = <String?>[user.username, user.name, user.email];
      for (final c in candidates) {
        final s = c?.toString().trim();
        if (s != null && s.isNotEmpty) return s;
      }
      return 'Unknown';
    })();
    final userInitial = username.isNotEmpty ? username[0].toUpperCase() : '?';
    final timeAgo = _formatTimeAgo(post.createdAt);
    final caption = (post.caption?.toString() ?? '').trim();
    final hasCaption = caption.isNotEmpty;
    final hasMedia = (post.media is List && post.media.isNotEmpty) &&
        ((post.url?.toString() ?? '').trim().isNotEmpty);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        
        // Post header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red[700],
                child: Text(userInitial,
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(username,
                            style: const TextStyle(
                                fontWeight: FontWeight.w600, fontSize: 13)),
                        const SizedBox(width: 6),
                        const Text('·',
                            style: TextStyle(color: Colors.grey)),
                        const SizedBox(width: 6),
                        const Text('Follow',
                            style: TextStyle(
                                color: Color(0xFF4361EE),
                                fontWeight: FontWeight.w600,
                                fontSize: 13)),
                      ],
                    ),
                    Row(
                      children: [
                        Text(timeAgo,
                            style:
                                const TextStyle(color: Colors.grey, fontSize: 11)),
                        const SizedBox(width: 4),
                        const Icon(Icons.public, size: 11, color: Colors.grey),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.more_horiz, color: Colors.grey),
              const SizedBox(width: 8),
              const Icon(Icons.close, color: Colors.grey, size: 18),
            ],
          ),
        ),

        // Post media / status (Facebook-like)
        if (hasMedia)
          Image.network(
            post.url,
            width: double.infinity,
            height: 320,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              width: double.infinity,
              height: 320,
              color: Colors.grey[200],
              child: const Center(
                child:
                    Icon(Icons.broken_image, size: 64, color: Colors.black26),
              ),
            ),
            loadingBuilder: (_, child, progress) => progress == null
                ? child
                : Container(
                    width: double.infinity,
                    height: 320,
                    color: Colors.grey[100],
                    child: const Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
          )
        else if (hasCaption)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
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
          ),

        // Caption
        if (hasMedia && hasCaption)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                children: [
                  TextSpan(
                    text: username,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' $caption'),
                ],
              ),
            ),
          ),

        // Actions row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Get.find<FeedController>().toggleLike(post.id),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                  child: Icon(
                    post.isLiked ? Icons.favorite : Icons.favorite_border,
                    size: 22,
                    color: post.isLiked ? Colors.red : null,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(_formatCount(post.likesCount),
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(width: 16),
              GestureDetector(
                onTap: () => Get.find<FeedController>().openPostDetail(post),
                behavior: HitTestBehavior.opaque,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                  child: Icon(Icons.chat_bubble_outline, size: 22),
                ),
              ),
              const SizedBox(width: 4),
              Text(_formatCount(post.commentsCount),
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const SizedBox(width: 16),
              const Icon(Icons.reply_outlined, size: 22),
              const SizedBox(width: 4),
              Text(_formatCount(post.sharesCount),
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
              const Spacer(),
              GestureDetector(
                onTap: () => Get.find<FeedController>().toggleSave(post.id),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 2),
                  child: Icon(
                    post.isSaved ? Icons.bookmark : Icons.bookmark_border,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1, thickness: 0.5),
      ],
    );
  }

  String _formatTimeAgo(DateTime dateTime) {
    final diff = DateTime.now().difference(dateTime);
    if (diff.inDays > 0) return '${diff.inDays}d';
    if (diff.inHours > 0) return '${diff.inHours}h';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m';
    return 'now';
  }

  String _formatCount(int count) {
    if (count >= 1000000) return '${(count / 1000000).toStringAsFixed(1)}M';
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}

// ─── Bottom Nav ─────────────────────────────────────

class _BottomNav extends StatelessWidget {
  const _BottomNav();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE0E0E0), width: 0.5)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 56,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                  icon: const Icon(Icons.home_filled),
                  onPressed: () => Get.offAllNamed(AppRoutes.FEED)),
              IconButton(
                  icon: const Icon(Icons.search_outlined),
                  onPressed: () {
                    Get.snackbar('Search', 'Search is not wired up yet',
                        snackPosition: SnackPosition.BOTTOM);
                  }),
              IconButton(
                  icon: const Icon(Icons.video_collection_outlined),
                  onPressed: () => Get.offAllNamed(AppRoutes.REELS)),
              IconButton(
                  icon: const Icon(Icons.shopping_bag_outlined),
                  onPressed: () {
                    Get.snackbar('Shop', 'Shop is not wired up yet',
                        snackPosition: SnackPosition.BOTTOM);
                  }),
              IconButton(
                  icon: const Icon(Icons.person_outline),
                  onPressed: () => Get.offAllNamed(AppRoutes.PROFILE)),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Shared widgets (auth screens) ──────────────────

class _AuthTextField extends StatelessWidget {
  final String label;
  final Function(String) onChanged;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;

  const _AuthTextField({
    required this.label,
    required this.onChanged,
    this.obscureText = false,
    this.suffixIcon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide:
              const BorderSide(color: Color(0xFF4361EE), width: 1.5),
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String label;
  final bool isLoading;
  final VoidCallback onTap;

  const _PrimaryButton({
    required this.label,
    required this.isLoading,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isLoading ? null : onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4361EE),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
            : Text(label,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(child: Divider(color: Color(0xFFE0E0E0))),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('or', style: TextStyle(color: Colors.grey)),
        ),
        Expanded(child: Divider(color: Color(0xFFE0E0E0))),
      ],
    );
  }
}

class _GoogleButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _GoogleButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFE0E0E0)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(label,
                style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87)),
            const SizedBox(width: 8),
            // Google G icon using colored text as a simple stand-in
            const Text('G',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF4285F4))),
          ],
        ),
      ),
    );
  }
}