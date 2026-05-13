import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../app/routes/app_routes.dart';
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
    return GridView.builder(
      padding: const EdgeInsets.all(2),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 2,
        mainAxisSpacing: 2,
      ),
      itemCount: 30,
      itemBuilder: (context, index) {
        return Image.network(
          'https://picsum.photos/id/${index + 1}/300/300',
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(color: Colors.grey[200]),
        );
      },
    );
  }
}
