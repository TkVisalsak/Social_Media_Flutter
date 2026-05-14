import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../app/routes/app_routes.dart';

class FollowListScreen extends StatefulWidget {
  final String userId;
  final String type; // 'followers' | 'following'
  const FollowListScreen({super.key, required this.userId, required this.type});

  @override
  State<FollowListScreen> createState() => _FollowListScreenState();
}

class _FollowListScreenState extends State<FollowListScreen> {
  List<UserModel> _users = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    final repo = Get.find<FollowRepository>();
    final res = widget.type == 'followers'
        ? await repo.getFollowers(widget.userId)
        : await repo.getFollowing(widget.userId);
    if (!mounted) return;
    if (res.success && res.data != null) {
      setState(() { _users = res.data!; _loading = false; });
    } else {
      setState(() { _error = res.error; _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.type == 'followers' ? 'Followers' : 'Following';
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: Text(title, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(child: Text(_error!, style: const TextStyle(color: Colors.grey)))
              : _users.isEmpty
                  ? Center(child: Text('No $title yet', style: const TextStyle(color: Colors.grey)))
                  : ListView.separated(
                      itemCount: _users.length,
                      separatorBuilder: (_, __) => Divider(height: 1, indent: 72, color: Colors.grey[100]),
                      itemBuilder: (_, i) {
                        final u = _users[i];
                        final name = u.username ?? u.fullName ?? u.email.split('@').first;
                        final pic  = u.profilePic;
                        return ListTile(
                          leading: CircleAvatar(
                            radius: 24,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: pic != null && pic.isNotEmpty ? NetworkImage(pic) : null,
                            child: pic == null || pic.isEmpty
                                ? Text(name.isNotEmpty ? name[0].toUpperCase() : '?',
                                    style: const TextStyle(fontWeight: FontWeight.bold))
                                : null,
                          ),
                          title: Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                          subtitle: u.fullName != null && u.username != null
                              ? Text(u.fullName!, style: const TextStyle(color: Colors.grey, fontSize: 13))
                              : null,
                          onTap: () => Get.toNamed(AppRoutes.OTHER_PROFILE, arguments: u),
                        );
                      },
                    ),
    );
  }
}
