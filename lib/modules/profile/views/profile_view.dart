import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/post_model.dart';
import '../controllers/highlights_controller.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        title: Obx(() => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              controller.username.value,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
            ),
            const Icon(Icons.keyboard_arrow_down, size: 20),
          ],
        )),
        actions: [
          IconButton(icon: const Icon(Icons.add_box_outlined), onPressed: () {}),
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => _showOptionsMenu(context),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return DefaultTabController(
          length: 5,
          child: NestedScrollView(
            physics: const BouncingScrollPhysics(),
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
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
                              child: Obx(() => CircleAvatar(
                                radius: 42,
                                backgroundColor: Colors.grey[100],
                                backgroundImage: controller.profilePic.value.isNotEmpty
                                    ? NetworkImage(controller.profilePic.value) as ImageProvider
                                    : null,
                                child: controller.profilePic.value.isEmpty
                                    ? Text(controller.username.value.isNotEmpty
                                        ? controller.username.value[0].toUpperCase() : '?',
                                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold))
                                    : null,
                              )),
                            ),
                            Expanded(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                children: [
                                  Obx(() => _StatItem(label: 'Posts',     value: '${controller.postsCount.value}')),
                                  Obx(() => _StatItem(
                                    label: 'Followers',
                                    value: '${controller.followersCount.value}',
                                    onTap: () => Get.toNamed(AppRoutes.FOLLOW_LIST,
                                        arguments: {'userId': controller.userId ?? '', 'type': 'followers'}),
                                  )),
                                  Obx(() => _StatItem(
                                    label: 'Following',
                                    value: '${controller.followingCount.value}',
                                    onTap: () => Get.toNamed(AppRoutes.FOLLOW_LIST,
                                        arguments: {'userId': controller.userId ?? '', 'type': 'following'}),
                                  )),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Obx(() => Text(controller.name.value,
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14))),
                            const Text('Digital Creator',
                                style: TextStyle(color: Colors.grey, fontSize: 14)),
                            const SizedBox(height: 2),
                            Obx(() => Text(controller.bio.value,
                                style: const TextStyle(fontSize: 14))),
                            const SizedBox(height: 4),
                            Obx(() {
                              final url = controller.website.value.trim();
                              if (url.isEmpty) {
                                return Row(
                                  children: const [
                                    Icon(Icons.link, size: 14, color: Colors.grey),
                                    SizedBox(width: 4),
                                    Text('Available',
                                        style: TextStyle(color: Colors.grey, fontSize: 14)),
                                  ],
                                );
                              }
                              return GestureDetector(
                                onTap: () async {
                                  final raw = url.startsWith('http') ? url : 'https://$url';
                                  final uri = Uri.tryParse(raw);
                                  if (uri != null) {
                                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                                  }
                                },
                                child: Row(
                                  children: [
                                    const Icon(Icons.link, size: 14, color: Color(0xFF00376B)),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(url,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                              color: Color(0xFF00376B),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            Expanded(
                              child: _ProfileButton(
                                label: 'Edit Profile',
                                onPressed: () => Get.toNamed(AppRoutes.EDIT_PROFILE),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: _ProfileButton(
                                label: 'Share Profile',
                                onPressed: () => controller.shareProfile(),
                              ),
                            ),
                            const SizedBox(width: 8),
                            _ProfileIconButton(
                              icon: Icons.person_add_outlined,
                              onPressed: () => Get.toNamed(AppRoutes.FRIEND_SUGGESTIONS),
                            ),
                          ],
                        ),
                      ),

                      const _HighlightsSection(),
                      const SizedBox(height: 10),
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
                        Tab(icon: Icon(Icons.favorite_border_rounded)),
                        Tab(icon: Icon(Icons.bookmark_border_rounded)),
                        Tab(icon: Icon(Icons.person_pin_outlined)),
                      ],
                    ),
                  ),
                ),
              ];
            },
            body: TabBarView(
              children: [
                _buildPostsGrid(),
                _buildShortsGrid(),
                _buildLikedPostsGrid(),
                _buildSavedPostsGrid(),
                const Center(child: Text('Photos and videos of you')),
              ],
            ),
          ),
        );
      }),
    );
  }

  void _showOptionsMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ProfileOptionsSheet(onLogout: controller.logout),
    );
  }

  Widget _buildPostsGrid() {
    return Obx(() {
      if (controller.isContentLoading.value && controller.myPosts.isEmpty) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      if (controller.myPosts.isEmpty) {
        return const Center(
          child: Text('No posts yet', style: TextStyle(color: Colors.grey)),
        );
      }
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
        ),
        itemCount: controller.myPosts.length,
        itemBuilder: (context, i) {
          final post = controller.myPosts[i];
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
              url, fit: BoxFit.cover,
              errorBuilder: (_, _, _) => Container(color: Colors.grey[200]),
            ),
          );
        },
      );
    });
  }

  Widget _buildShortsGrid() {
    return Obx(() {
      if (controller.isContentLoading.value && controller.myShorts.isEmpty) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      if (controller.myShorts.isEmpty) {
        return const Center(
          child: Text('No reels yet', style: TextStyle(color: Colors.grey)),
        );
      }
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
        ),
        itemCount: controller.myShorts.length,
        itemBuilder: (context, i) {
          final short = controller.myShorts[i];
          final thumb = short.thumbnailUrl;
          return Stack(
            fit: StackFit.expand,
            children: [
              if (thumb != null && thumb.isNotEmpty)
                Image.network(thumb, fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(color: Colors.black))
              else
                Container(color: Colors.black),
              const Align(
                alignment: Alignment.bottomRight,
                child: Padding(
                  padding: EdgeInsets.all(4),
                  child: Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          );
        },
      );
    });
  }

  Widget _buildLikedPostsGrid() {
    return Obx(() {
      if (controller.isContentLoading.value && controller.likedPosts.isEmpty) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      if (controller.likedPosts.isEmpty) {
        return const Center(
          child: Text('No liked posts yet', style: TextStyle(color: Colors.grey)),
        );
      }
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
        ),
        itemCount: controller.likedPosts.length,
        itemBuilder: (context, i) {
          final PostModel post = controller.likedPosts[i];
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
              url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
            ),
          );
        },
      );
    });
  }

  Widget _buildSavedPostsGrid() {
    return Obx(() {
      if (controller.isContentLoading.value && controller.savedPosts.isEmpty) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      if (controller.savedPosts.isEmpty) {
        return const Center(
          child: Text('No saved posts yet', style: TextStyle(color: Colors.grey)),
        );
      }
      return GridView.builder(
        padding: EdgeInsets.zero,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1,
        ),
        itemCount: controller.savedPosts.length,
        itemBuilder: (context, i) {
          final PostModel post = controller.savedPosts[i];
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
              url, fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(color: Colors.grey[200]),
            ),
          );
        },
      );
    });
  }
}

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
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.black)),
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          padding: EdgeInsets.zero,
        ),
        child: Text(label,
            style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 14)),
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
      width: 32, height: 32,
      decoration: BoxDecoration(color: Colors.grey[100], borderRadius: BorderRadius.circular(8)),
      child: IconButton(
        icon: Icon(icon, size: 18, color: Colors.black),
        onPressed: onPressed,
        padding: EdgeInsets.zero,
      ),
    );
  }
}

class _HighlightsSection extends StatelessWidget {
  const _HighlightsSection();

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HighlightsController>();
    return SizedBox(
      height: 100,
      child: Obx(() => ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _HighlightItem(
            label: 'New',
            isAdd: true,
            onTap: () => _showCreateDialog(context, ctrl),
          ),
          ...ctrl.highlights.map((h) => _HighlightItem(
            label: h.title,
            coverUrl: h.coverUrl,
            onLongPress: () => _confirmDelete(context, ctrl, h.id),
          )),
        ],
      )),
    );
  }

  void _showCreateDialog(BuildContext context, HighlightsController ctrl) {
    final nameCtrl = TextEditingController();
    final picker = ImagePicker();
    XFile? pickedImage;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          title: const Text('New Highlight'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Cover photo picker
              GestureDetector(
                onTap: () async {
                  final img = await picker.pickImage(
                    source: ImageSource.gallery,
                    imageQuality: 80,
                  );
                  if (img != null) {
                    setState(() => pickedImage = img);
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.grey[100],
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: pickedImage != null
                      ? ClipOval(
                          child: Image.file(
                            File(pickedImage!.path),
                            fit: BoxFit.cover,
                            width: 80,
                            height: 80,
                          ),
                        )
                      : const Icon(Icons.add_a_photo_outlined,
                          size: 32, color: Colors.grey),
                ),
              ),
              const SizedBox(height: 4),
              const Text('Add cover photo',
                  style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 12),
              TextField(
                controller: nameCtrl,
                autofocus: true,
                decoration: const InputDecoration(hintText: 'Highlight name'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final t = nameCtrl.text.trim();
                if (t.isNotEmpty) {
                  ctrl.createHighlight(t, coverImagePath: pickedImage?.path);
                }
                Navigator.pop(context);
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, HighlightsController ctrl, String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Highlight?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () { ctrl.deleteHighlight(id); Navigator.pop(context); },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _HighlightItem extends StatelessWidget {
  final String label;
  final bool isAdd;
  final String? coverUrl;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  const _HighlightItem({required this.label, this.isAdd = false, this.coverUrl, this.onTap, this.onLongPress});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Padding(
        padding: const EdgeInsets.only(right: 18),
        child: Column(
          children: [
            Container(
              width: 64, height: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: isAdd
                  ? const Icon(Icons.add, size: 30)
                  : coverUrl != null && coverUrl!.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(coverUrl!))
                      : CircleAvatar(
                          backgroundColor: Colors.grey[100],
                          child: const Icon(Icons.collections_outlined, color: Colors.grey),
                        ),
            ),
            const SizedBox(height: 6),
            SizedBox(
              width: 64,
              child: Text(label,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileOptionsSheet extends StatelessWidget {
  const _ProfileOptionsSheet({required this.onLogout});

  final VoidCallback onLogout;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // drag handle
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 4),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 8),
          _MenuItem(
            icon: Icons.settings_outlined,
            label: 'Settings & Privacy',
            onTap: () { Navigator.pop(context); Get.toNamed(AppRoutes.SETTINGS); },
          ),
          _MenuItem(icon: Icons.archive_outlined,       label: 'Archive'),
          _MenuItem(icon: Icons.bar_chart_outlined,     label: 'Your activity'),
          _MenuItem(icon: Icons.notifications_outlined, label: 'Notifications'),
          _MenuItem(icon: Icons.qr_code_outlined,       label: 'QR code'),
          _MenuItem(icon: Icons.bookmark_border,        label: 'Saved'),
          const Divider(height: 1, thickness: 0.5, indent: 16, endIndent: 16),
          _MenuItem(
            icon: Icons.logout,
            label: 'Log out',
            color: Colors.red,
            onTap: () {
              Navigator.of(context).pop();
              onLogout();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    this.color,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final c = color ?? Colors.black;
    return InkWell(
      onTap: onTap ?? () => Navigator.of(context).pop(),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Icon(icon, size: 24, color: c),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(fontSize: 15, color: c, fontWeight: FontWeight.w400),
            ),
          ],
        ),
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
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(color: Colors.white, child: _tabBar);
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) => false;
}
