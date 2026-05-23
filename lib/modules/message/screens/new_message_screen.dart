import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/repositories/user_repository.dart';
import '../controllers/message_controller.dart';

class NewMessageScreen extends StatefulWidget {
  const NewMessageScreen({super.key});
  @override
  State<NewMessageScreen> createState() => _NewMessageScreenState();
}

class _NewMessageScreenState extends State<NewMessageScreen> {
  final _searchCtrl = TextEditingController();
  List<UserModel> _results        = [];
  List<UserModel> _selected       = [];
  List<UserModel> _followingList  = [];
  bool            _loading        = false;
  bool            _loadingFollowing = false;
  bool            _isGroup        = false;
  Timer?          _debounce;

  @override
  void initState() {
    super.initState();
    _loadFollowing();
  }

  Future<void> _loadFollowing() async {
    final me = await LocalStorage.user;
    if (me == null || !mounted) return;
    setState(() => _loadingFollowing = true);
    final repo = Get.find<FollowRepository>();
    final res = await repo.getFollowing(me.id);
    if (mounted) {
      setState(() {
        if (res.success) _followingList = res.data ?? [];
        _loadingFollowing = false;
      });
    }
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _search(String q) async {
    _debounce?.cancel();
    if (q.trim().isEmpty) { setState(() => _results = []); return; }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _loading = true);
      final res = await Get.find<UserRepository>().search(q.trim());
      if (mounted) setState(() { _results = res.data ?? []; _loading = false; });
    });
  }

  void _toggleSelect(UserModel u) {
    setState(() {
      if (_selected.any((s) => s.id == u.id)) {
        _selected.removeWhere((s) => s.id == u.id);
      } else {
        _selected.add(u);
      }
    });
  }

  Future<void> _openDm(UserModel u) async {
    final repo = Get.find<MessageRepository>();
    final res  = await repo.getOrCreateDm(u.id);
    if (!mounted) return;
    if (res.success && res.data != null) {
      if (Get.isRegistered<DirectController>()) {
        Get.find<DirectController>().fetchConversations(refresh: true);
      }
      Navigator.pop(context);
      Get.toNamed(AppRoutes.CHAT, arguments: res.data)?.then((_) {
        if (Get.isRegistered<DirectController>()) {
          Get.find<DirectController>().fetchConversations(refresh: true);
        }
      });
    } else {
      Get.snackbar('Error', res.error ?? 'Cannot open DM',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> _createGroup() async {
    if (_selected.isEmpty) return;
    _showGroupNameDialog();
  }

  void _showGroupNameDialog() {
    final nameCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Group name'),
        content: TextField(
          controller: nameCtrl,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter group name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final name = nameCtrl.text.trim();
              if (name.isEmpty) return;
              Navigator.pop(context); // close dialog
              await _doCreateGroup(name);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _doCreateGroup(String name) async {
    setState(() => _loading = true);
    final repo = Get.find<MessageRepository>();
    final res  = await repo.createGroup(
      name: name,
      memberIds: _selected.map((u) => u.id).toList(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (res.success && res.data != null) {
      if (Get.isRegistered<DirectController>()) {
        Get.find<DirectController>().fetchConversations(refresh: true);
      }
      Navigator.pop(context); // close NewMessageScreen
      Get.toNamed(AppRoutes.CHAT, arguments: res.data)?.then((_) {
        if (Get.isRegistered<DirectController>()) {
          Get.find<DirectController>().fetchConversations(refresh: true);
        }
      });
    } else {
      Get.snackbar('Error', res.error ?? 'Failed to create group',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('New message',
            style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.w700,
                fontSize: 16)),
        centerTitle: true,
        actions: [
          if (_selected.isNotEmpty)
            TextButton(
              onPressed:
                  _isGroup ? _createGroup : () => _openDm(_selected.first),
              child: Text(
                _isGroup ? 'Create' : 'Open',
                style: const TextStyle(
                    color: Color(0xFF3797F0), fontWeight: FontWeight.w700),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          // To: field
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text('To:',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 16)),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _searchCtrl,
                    autofocus: true,
                    onChanged: _search,
                    decoration: const InputDecoration(
                      hintText: 'Search people...',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Selected chips
          if (_selected.isNotEmpty)
            Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _selected.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) {
                  final u = _selected[i];
                  final name =
                      u.username ?? u.fullName ?? u.email.split('@').first;
                  return Chip(
                    label: Text(name,
                        style: const TextStyle(fontSize: 12)),
                    onDeleted: () => _toggleSelect(u),
                    visualDensity: VisualDensity.compact,
                  );
                },
              ),
            ),

          const Divider(height: 1),

          // Group toggle
          SwitchListTile.adaptive(
            title: const Text('Create group chat',
                style: TextStyle(
                    fontSize: 15, fontWeight: FontWeight.w600)),
            value: _isGroup,
            onChanged: (v) => setState(() => _isGroup = v),
            activeColor: const Color(0xFF3797F0),
          ),

          const Divider(height: 1),

          // Results
          Expanded(
            child: Builder(builder: (context) {
              // When in group mode with an empty search field, show the
              // people the current user already follows so they can quickly
              // pick friends without needing to type.
              final displayList = (_isGroup && _searchCtrl.text.isEmpty)
                  ? _followingList
                  : _results;

              final isWorking = _loading ||
                  (_isGroup && _searchCtrl.text.isEmpty && _loadingFollowing);

              if (isWorking) {
                return const Center(child: CircularProgressIndicator());
              }

              if (displayList.isEmpty) {
                return Center(
                  child: Text(
                    _isGroup && _searchCtrl.text.isEmpty
                        ? 'No following users found'
                        : _searchCtrl.text.isEmpty
                            ? 'Search for someone to message'
                            : 'No results',
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              }

              return ListView.separated(
                itemCount: displayList.length,
                separatorBuilder: (_, __) =>
                    Divider(height: 1, indent: 72, color: Colors.grey[100]),
                itemBuilder: (_, i) {
                  final u = displayList[i];
                  final name =
                      u.username ?? u.fullName ?? u.email.split('@').first;
                  final pic = u.profilePic;
                  final sel = _selected.any((s) => s.id == u.id);
                  return ListTile(
                    onTap:
                        _isGroup ? () => _toggleSelect(u) : () => _openDm(u),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.grey[200],
                      backgroundImage:
                          pic != null && pic.isNotEmpty ? NetworkImage(pic) : null,
                      child: pic == null || pic.isEmpty
                          ? Text(
                              name.isNotEmpty ? name[0].toUpperCase() : '?',
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold))
                          : null,
                    ),
                    title: Text(name,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 15)),
                    trailing: _isGroup
                        ? Icon(
                            sel ? Icons.check_circle : Icons.circle_outlined,
                            color: sel
                                ? const Color(0xFF3797F0)
                                : Colors.grey[400])
                        : null,
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }
}
