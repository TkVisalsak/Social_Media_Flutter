import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../controllers/search_controller.dart';

class SearchView extends StatelessWidget {
  const SearchView({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<UserSearchController>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _SearchBar(onChanged: ctrl.onQueryChanged),
            Expanded(
              child: Obx(() {
                if (ctrl.query.value.isEmpty) {
                  return _ExploreGrid();
                }
                if (ctrl.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  );
                }
                if (ctrl.error.value != null) {
                  return Center(
                    child: Text(
                      ctrl.error.value!,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  );
                }
                if (ctrl.results.isEmpty) {
                  return const Center(
                    child: Text(
                      'No users found',
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: ctrl.results.length,
                  itemBuilder: (_, i) => _UserTile(user: ctrl.results[i]),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.onChanged});

  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Container(
        height: 44,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFEFF1F4),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Row(
          children: [
            const Icon(Icons.search, color: Color(0xFF8E939A), size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                onChanged: onChanged,
                style: const TextStyle(color: Colors.black, fontSize: 15),
                decoration: const InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'Search users',
                  hintStyle: TextStyle(color: Color(0xFF8E939A), fontSize: 15),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({required this.user});

  final UserModel user;

  @override
  Widget build(BuildContext context) {
    final displayName = user.fullName ?? user.username ?? '';
    final sub = user.fullName != null ? '@${user.username ?? ''}' : '';

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: const Color(0xFFEFF1F4),
        backgroundImage: (user.profilePic != null && user.profilePic!.isNotEmpty)
            ? NetworkImage(user.profilePic!)
            : null,
        child: (user.profilePic == null || user.profilePic!.isEmpty)
            ? Text(
                (user.username ?? '?')[0].toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF8E939A),
                ),
              )
            : null,
      ),
      title: Text(
        displayName.isNotEmpty ? displayName : '@${user.username ?? ''}',
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: sub.isNotEmpty
          ? Text(sub, style: const TextStyle(color: Color(0xFF8E939A), fontSize: 12))
          : null,
      onTap: () => Get.toNamed(AppRoutes.OTHER_PROFILE, arguments: user),
    );
  }
}

class _ExploreGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<UserSearchController>();
    return Obx(() {
      if (ctrl.isExploreLoading.value) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      if (ctrl.explorePosts.isEmpty) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.explore_outlined, size: 48, color: Colors.grey),
              const SizedBox(height: 12),
              const Text('Nothing to explore yet',
                  style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 12),
              TextButton(
                onPressed: ctrl.refreshExplore,
                child: const Text('Refresh'),
              ),
            ],
          ),
        );
      }

      final posts = ctrl.explorePosts;
      return RefreshIndicator(
        onRefresh: ctrl.refreshExplore,
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(2),
              sliver: _ExploreSliver(posts: posts),
            ),
          ],
        ),
      );
    });
  }
}

/// Instagram-style explore layout:
/// Repeating pattern of 6 posts → 3 normal + 1 wide (2-col) alternating sides.
/// Pattern per block of 7:
///   [large (rows 0-1, col 0-1)] [small top-right] [small bottom-right]
///   then 3 normal singles
class _ExploreSliver extends StatelessWidget {
  final List<PostModel> posts;
  const _ExploreSliver({required this.posts});

  @override
  Widget build(BuildContext context) {
    final tiles = <Widget>[];
    int i = 0;
    bool featuredLeft = true; // alternate large tile side

    while (i < posts.length) {
      final remaining = posts.length - i;

      // If at least 5 left, build a featured block (1 large + 2 small + 2 small row)
      if (remaining >= 5) {
        tiles.add(_buildFeaturedBlock(posts, i, featuredLeft));
        i += 5;
        featuredLeft = !featuredLeft;
      } else {
        // Remaining posts as simple 3-col rows
        tiles.add(_buildNormalRow(posts, i, min: remaining));
        i += remaining;
      }
    }

    return SliverList(delegate: SliverChildListDelegate(tiles));
  }

  // 1 large tile (2×2) + 2 small tiles beside it, then 3 normal tiles below
  Widget _buildFeaturedBlock(List<PostModel> posts, int start, bool largeLeft) {
    final large  = posts[start];
    final sm1    = posts[start + 1];
    final sm2    = posts[start + 2];
    final norm1  = posts[start + 3];
    final norm2  = start + 4 < posts.length ? posts[start + 4] : null;

    final largeCell = _ExploreCell(post: large, flex: 2);
    final smallCol  = Column(
      children: [
        Expanded(child: _ExploreCell(post: sm1)),
        const SizedBox(height: 2),
        Expanded(child: _ExploreCell(post: sm2)),
      ],
    );

    final topRow = SizedBox(
      height: (MediaQuery.of(Get.context!).size.width - 4) * 2 / 3,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: largeLeft
            ? [
                Expanded(flex: 2, child: largeCell),
                const SizedBox(width: 2),
                Expanded(flex: 1, child: smallCol),
              ]
            : [
                Expanded(flex: 1, child: smallCol),
                const SizedBox(width: 2),
                Expanded(flex: 2, child: largeCell),
              ],
      ),
    );

    final bottomRow = _buildNormalRow(
      [norm1, ?norm2],
      0,
    );

    return Column(
      children: [
        topRow,
        const SizedBox(height: 2),
        bottomRow,
        const SizedBox(height: 2),
      ],
    );
  }

  Widget _buildNormalRow(List<PostModel> posts, int start, {int? min}) {
    final count = (min ?? posts.length - start).clamp(0, 3);
    if (count == 0) return const SizedBox.shrink();
    return Row(
      children: [
        for (int j = 0; j < count; j++) ...[
          if (j > 0) const SizedBox(width: 2),
          Expanded(child: _ExploreCell(post: posts[start + j])),
        ],
        // Fill empty slots with grey boxes so the row is always 3-wide
        for (int j = count; j < 3; j++) ...[
          const SizedBox(width: 2),
          Expanded(child: Container(color: Colors.grey[100])),
        ],
      ],
    );
  }
}

class _ExploreCell extends StatelessWidget {
  final PostModel post;
  final int flex;
  const _ExploreCell({required this.post, this.flex = 1});

  @override
  Widget build(BuildContext context) {
    final url = post.firstImageUrl;
    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.POST_DETAIL, arguments: post),
      child: AspectRatio(
        aspectRatio: 1,
        child: url != null && url.isNotEmpty
            ? Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, progress) =>
                    progress == null ? child : Container(color: Colors.grey[200]),
                errorBuilder: (context, err, stack) => Container(color: Colors.grey[200]),
              )
            : Container(color: Colors.grey[200]),
      ),
    );
  }
}
