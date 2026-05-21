import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/repost_model.dart';
import '../../../data/models/short_model.dart';
import '../../../shared/widgets/social_action_buttons.dart';
import '../../feed/controllers/feed_controller.dart';
import '../../shorts/screens/user_shorts_player.dart';
import '../controllers/other_profile_controller.dart';

class OtherProfileView extends GetView<OtherProfileController> {
  const OtherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: 3,
        child: Stack(
          children: [
            _OtherProfileBody(controller: controller),
            Obx(() => controller.isLoading.value
                ? Container(
                    color: Colors.white,
                    child: const Center(child: CircularProgressIndicator()),
                  )
                : const SizedBox.shrink()),
          ],
        ),
      ),
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  static void _showProfileOptions(BuildContext context) {
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
    );
  }
}

// ─── Body (stable — lives outside Obx so NestedScrollView is never recreated) ─

class _OtherProfileBody extends StatelessWidget {
  final OtherProfileController controller;
  const _OtherProfileBody({required this.controller});

  @override
  Widget build(BuildContext context) {
    final user = controller.user;
    final username = user.username ?? user.fullName ?? 'user';
    final profilePic = user.profilePic ?? '';

    return NestedScrollView(
      physics: const BouncingScrollPhysics(),
      headerSliverBuilder: (context, _) => [
        SliverAppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
            onPressed: () => Get.back(),
          ),
          title: Text(username,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 20)),
          actions: [
            IconButton(
              icon: const Icon(Icons.more_horiz),
              onPressed: () => OtherProfileView._showProfileOptions(context),
            ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 24, 10),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey[200]!),
                      ),
                      child: CircleAvatar(
                        radius: 42,
                        backgroundColor: Colors.grey[100],
                        backgroundImage: profilePic.isNotEmpty
                            ? NetworkImage(profilePic) as ImageProvider
                            : null,
                        child: profilePic.isEmpty
                            ? Text(
                                username.isNotEmpty ? username[0].toUpperCase() : '?',
                                style: const TextStyle(
                                    fontSize: 28, fontWeight: FontWeight.bold))
                            : null,
                      ),
                    ),
                    Expanded(
                      child: Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _StatItem(
                              label: 'Posts',
                              value: '${controller.postsCount.value}'),
                          _StatItem(
                              label: 'Followers',
                              value: OtherProfileView._fmt(controller.followersCount.value),
                              onTap: () => Get.toNamed(AppRoutes.FOLLOW_LIST,
                                  arguments: {'userId': controller.user.id, 'type': 'followers'})),
                          _StatItem(
                              label: 'Following',
                              value: OtherProfileView._fmt(controller.followingCount.value),
                              onTap: () => Get.toNamed(AppRoutes.FOLLOW_LIST,
                                  arguments: {'userId': controller.user.id, 'type': 'following'})),
                        ],
                      )),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user.fullName ?? username,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14)),
                    if (user.bio != null && user.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(user.bio!, style: const TextStyle(fontSize: 14)),
                    ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: _FollowButton(controller: controller)),
                    const SizedBox(width: 8),
                    Expanded(child: _MessageButton(controller: controller)),
                    const SizedBox(width: 8),
                    _ProfileIconButton(
                        icon: Icons.person_add_outlined, onPressed: () {}),
                  ],
                ),
              ),
              const SizedBox(height: 4),
            ],
          ),
        ),
        SliverPersistentHeader(
          pinned: true,
          delegate: _SliverTabBarDelegate(
            const TabBar(
              indicatorColor: Colors.black,
              indicatorWeight: 1,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(icon: Icon(Icons.grid_on)),
                Tab(icon: Icon(Icons.video_collection_outlined)),
                Tab(icon: Icon(Icons.repeat_rounded)),
              ],
            ),
          ),
        ),
      ],
      body: TabBarView(
        children: [
          _PostsGrid(controller: controller),
          _ShortsGrid(controller: controller),
          _RepostsList(controller: controller),
        ],
      ),
    );
  }
}

// ─── Follow button ────────────────────────────────────────────────────────────

class _FollowButton extends StatelessWidget {
  final OtherProfileController controller;
  const _FollowButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final following = controller.isFollowing.value;
      final loading   = controller.isFollowLoading.value;
      return IgnorePointer(
        ignoring: loading,
        child: FollowButton(
          isFollowing: following,
          onTap: (_) => controller.toggleFollow(),
          brandColor: Colors.black,
          height: 32,
          fillWidth: true,
        ),
      );
    });
  }
}

// ─── Message button ───────────────────────────────────────────────────────────

class _MessageButton extends StatelessWidget {
  final OtherProfileController controller;
  const _MessageButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isDmLoading.value;
      return SizedBox(
        height: 32,
        child: TextButton(
          onPressed: loading ? null : controller.openDM,
          style: TextButton.styleFrom(
            backgroundColor: Colors.grey[100],
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.zero,
          ),
          child: loading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.black),
                )
              : const Text('Message',
                  style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14)),
        ),
      );
    });
  }
}

// ─── Posts grid ───────────────────────────────────────────────────────────────

class _PostsGrid extends StatelessWidget {
  final OtherProfileController controller;
  const _PostsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final posts = controller.posts;
      if (posts.isEmpty) {
        return const Center(
            child: Text('No posts yet', style: TextStyle(color: Colors.grey)));
      }
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
        ),
        itemCount: posts.length,
        itemBuilder: (_, i) {
          final post = posts[i];
          final url = post.firstImageUrl;
          if (url == null || url.isEmpty) {
            return Container(
              color: Colors.grey[200],
              child: const Icon(Icons.image_outlined, color: Colors.grey),
            );
          }
          return GestureDetector(
            onTap: () => controller.openPostDetail(post),
            child: Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: Colors.grey[200]),
            ),
          );
        },
      );
    });
  }
}

// ─── Shorts grid ──────────────────────────────────────────────────────────────

class _ShortsGrid extends StatelessWidget {
  final OtherProfileController controller;
  const _ShortsGrid({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final shorts = controller.shorts;
      if (shorts.isEmpty) {
        return const Center(
            child: Text('No reels yet', style: TextStyle(color: Colors.grey)));
      }
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
        ),
        itemCount: shorts.length,
        itemBuilder: (_, i) {
          final short = shorts[i];
          return GestureDetector(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserShortsPlayer(
                  shorts: controller.shorts.toList(),
                  initialIndex: i,
                ),
              ),
            ),
            child: _ShortThumbnail(short: short),
          );
        },
      );
    });
  }
}

// ─── Reposts list ─────────────────────────────────────────────────────────────

class _RepostsList extends StatelessWidget {
  final OtherProfileController controller;
  const _RepostsList({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final reposts = controller.reposts;
      if (reposts.isEmpty) {
        return const Center(
            child:
                Text('No reposts yet', style: TextStyle(color: Colors.grey)));
      }
      return ListView.separated(
        padding: const EdgeInsets.symmetric(vertical: 8),
        itemCount: reposts.length,
        separatorBuilder: (_, __) =>
            const Divider(height: 1, indent: 16, endIndent: 16),
        itemBuilder: (_, i) => _RepostTile(repost: reposts[i], ctrl: controller),
      );
    });
  }
}

class _RepostTile extends StatelessWidget {
  final RepostModel repost;
  final OtherProfileController ctrl;
  const _RepostTile({required this.repost, required this.ctrl});

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1) return '${d.inDays}d ago';
    if (d.inHours >= 1) return '${d.inHours}h ago';
    if (d.inMinutes >= 1) return '${d.inMinutes}m ago';
    return 'just now';
  }

  static String _fmt(int n) =>
      n >= 1000 ? '${(n / 1000).toStringAsFixed(1)}K' : '$n';

  @override
  Widget build(BuildContext context) {
    final isShort = repost.contentType == RepostContentType.short;
    final post    = isShort ? null : ctrl.repostPostCache[repost.contentId];
    final timeAgo = _timeAgo(repost.createdAt);
    final imgUrl  = post?.firstImageUrl;

    return GestureDetector(
      onTap: () {
        if (post != null) {
          Get.toNamed(AppRoutes.POST_DETAIL, arguments: post);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 72,
                height: 72,
                child: imgUrl != null && imgUrl.isNotEmpty
                    ? Image.network(imgUrl, fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            Container(color: Colors.grey[200]))
                    : Container(
                        color: Colors.grey[100],
                        child: Icon(
                          isShort
                              ? Icons.video_collection_outlined
                              : Icons.image_outlined,
                          color: Colors.grey[400],
                          size: 28,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isShort ? 'Reposted a Reel' : 'Reposted a Post',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  if (repost.caption != null && repost.caption!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        repost.caption!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.black87, fontSize: 13),
                      ),
                    ),
                  const SizedBox(height: 6),
                  if (post != null && Get.isRegistered<FeedController>())
                    _LikeSaveRow(post: post, fmt: _fmt),
                  const SizedBox(height: 4),
                  Text(timeAgo,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LikeSaveRow extends StatelessWidget {
  final dynamic post; // PostModel
  final String Function(int) fmt;
  const _LikeSaveRow({required this.post, required this.fmt});

  @override
  Widget build(BuildContext context) {
    final feedCtrl = Get.find<FeedController>();

    dynamic live() {
      final i = feedCtrl.posts.indexWhere((p) => p.id == post.id);
      return i >= 0 ? feedCtrl.posts[i] : post;
    }

    return Row(
      children: [
        Obx(() {
          final p = live();
          return GestureDetector(
            onTap: () => feedCtrl.toggleLike(post.id),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  p.isLiked
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  size: 18,
                  color: p.isLiked ? const Color(0xFFFF4D6D) : Colors.grey,
                ),
                const SizedBox(width: 3),
                Text(fmt(p.likesCount),
                    style:
                        const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          );
        }),
        const SizedBox(width: 16),
        Obx(() {
          final p = live();
          return GestureDetector(
            onTap: () => feedCtrl.toggleSave(post.id),
            behavior: HitTestBehavior.opaque,
            child: Icon(
              p.isSaved ? Icons.bookmark : Icons.bookmark_outline,
              size: 18,
              color: p.isSaved ? AppColors.save : Colors.grey,
            ),
          );
        }),
      ],
    );
  }
}

// ─── Short thumbnail with counts ──────────────────────────────────────────────

class _ShortThumbnail extends StatelessWidget {
  final ShortModel short;
  const _ShortThumbnail({required this.short});

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
  }

  @override
  Widget build(BuildContext context) {
    final thumb = short.thumbnailUrl;
    return Stack(
      fit: StackFit.expand,
      children: [
        if (thumb != null && thumb.isNotEmpty)
          Image.network(
            thumb,
            fit: BoxFit.cover,
            loadingBuilder: (_, child, progress) =>
                progress == null ? child : Container(color: Colors.grey[200]),
            errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]),
          )
        else
          Container(color: Colors.grey[300]),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: [0.45, 1.0],
              colors: [Colors.transparent, Colors.black54],
            ),
          ),
        ),
        // Like + repost counts bottom-left
        Positioned(
          bottom: 5, left: 6,
          child: Row(
            children: [
              const Icon(Icons.favorite_rounded, color: Colors.white, size: 13),
              const SizedBox(width: 2),
              Text(_fmt(short.likeCount),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
              const SizedBox(width: 8),
              const Icon(Icons.repeat_rounded, color: Colors.white, size: 13),
              const SizedBox(width: 2),
              Text(_fmt(short.repostCount),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
        // Play icon bottom-right
        const Positioned(
          bottom: 5, right: 6,
          child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
        ),
      ],
    );
  }
}

// ─── Shared widgets ───────────────────────────────────────────────────────────

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback? onTap;
  const _StatItem({required this.label, required this.value, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(value,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(fontSize: 14, color: Colors.black)),
        ],
      ),
    );
  }
}

class _ProfileButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const _ProfileButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 32,
      child: TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          backgroundColor: Colors.grey[100],
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Text(label,
            style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w600,
                fontSize: 14)),
      ),
    );
  }
}

class _ProfileIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  const _ProfileIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8)),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.black),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverTabBarDelegate(this._tabBar);
  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate old) => false;
}
