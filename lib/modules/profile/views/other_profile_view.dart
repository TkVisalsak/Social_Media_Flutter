import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/repost_model.dart';
import '../../shorts/screens/user_shorts_player.dart';
import '../controllers/other_profile_controller.dart';

class OtherProfileView extends GetView<OtherProfileController> {
  const OtherProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        final user = controller.user;
        final username = user.username ?? user.fullName ?? 'user';
        final profilePic = user.profilePic ?? '';

        return DefaultTabController(
          length: 3,
          child: NestedScrollView(
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
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 20)),
                actions: [
                  IconButton(icon: const Icon(Icons.more_horiz), onPressed: () {}),
                ],
              ),

              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Avatar + Stats ──────────────────────────────
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
                                      username.isNotEmpty
                                          ? username[0].toUpperCase()
                                          : '?',
                                      style: const TextStyle(
                                          fontSize: 28,
                                          fontWeight: FontWeight.bold))
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
                                    value: _fmt(controller.followersCount.value),
                                    onTap: () => Get.toNamed(AppRoutes.FOLLOW_LIST,
                                        arguments: {'userId': controller.user.id, 'type': 'followers'}),
                                ),
                                _StatItem(
                                    label: 'Following',
                                    value: _fmt(controller.followingCount.value),
                                    onTap: () => Get.toNamed(AppRoutes.FOLLOW_LIST,
                                        arguments: {'userId': controller.user.id, 'type': 'following'}),
                                ),
                              ],
                            )),
                          ),
                        ],
                      ),
                    ),

                    // ── Bio ──────────────────────────────────────────
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user.fullName ?? username,
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 14)),
                          if (user.bio != null && user.bio!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(user.bio!,
                                style: const TextStyle(fontSize: 14)),
                          ],
                        ],
                      ),
                    ),

                    // ── Action buttons ───────────────────────────────
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Expanded(child: _FollowButton(controller: controller)),
                          const SizedBox(width: 8),
                          Expanded(child: _MessageButton(controller: controller)),
                          const SizedBox(width: 8),
                          _ProfileIconButton(
                              icon: Icons.person_add_outlined,
                              onPressed: () {}),
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
          ),
        );
      }),
    );
  }

  static String _fmt(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
    return '$n';
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
      return SizedBox(
        height: 32,
        child: TextButton(
          onPressed: loading ? null : controller.toggleFollow,
          style: TextButton.styleFrom(
            backgroundColor: following ? Colors.grey[100] : Colors.black,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8)),
            padding: EdgeInsets.zero,
          ),
          child: loading
              ? SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: following ? Colors.black : Colors.white,
                  ),
                )
              : Text(
                  following ? 'Following' : 'Follow',
                  style: TextStyle(
                    color: following ? Colors.black : Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
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
          final thumb = short.thumbnailUrl;
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
            child: Stack(
              fit: StackFit.expand,
              children: [
                if (thumb != null && thumb.isNotEmpty)
                  Image.network(
                    thumb,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: Colors.black),
                  )
                else
                  Container(color: Colors.black),
                const Align(
                  alignment: Alignment.bottomRight,
                  child: Padding(
                    padding: EdgeInsets.all(4),
                    child: Icon(Icons.play_arrow_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ],
            ),
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
        itemBuilder: (_, i) => _RepostTile(repost: reposts[i]),
      );
    });
  }
}

class _RepostTile extends StatelessWidget {
  final RepostModel repost;
  const _RepostTile({required this.repost});

  @override
  Widget build(BuildContext context) {
    final isShort = repost.contentType == RepostContentType.short;
    final diff    = DateTime.now().difference(repost.createdAt);
    final timeAgo = diff.inDays >= 1
        ? '${diff.inDays}d ago'
        : diff.inHours >= 1
            ? '${diff.inHours}h ago'
            : '${diff.inMinutes}m ago';

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          isShort ? Icons.video_collection_outlined : Icons.image_outlined,
          color: Colors.grey[600],
          size: 22,
        ),
      ),
      title: Text(
        isShort ? 'Reposted a Reel' : 'Reposted a Post',
        style:
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: repost.caption != null && repost.caption!.isNotEmpty
          ? Text(repost.caption!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey, fontSize: 13))
          : Text(timeAgo,
              style: const TextStyle(color: Colors.grey, fontSize: 12)),
      trailing: Text(timeAgo,
          style: const TextStyle(color: Colors.grey, fontSize: 12)),
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
