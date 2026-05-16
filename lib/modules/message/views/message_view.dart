import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/message_model.dart';
import '../controllers/message_controller.dart';
import '../screens/new_message_screen.dart';
import '../widgets/chat_message_tile.dart';
import '../widgets/chat_search_bar.dart';

class DirectView extends GetView<DirectController> {
  const DirectView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: _ChatScreenBody(controller: controller),
      ),
    );
  }
}

class _ChatScreenBody extends StatefulWidget {
  final DirectController controller;
  const _ChatScreenBody({required this.controller});

  @override
  State<_ChatScreenBody> createState() => _ChatScreenBodyState();
}

class _ChatScreenBodyState extends State<_ChatScreenBody> {
  final _searchController = TextEditingController();
  final _searchFocus      = FocusNode();
  bool   _searchActive    = false;
  String _query           = '';

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
  }

  List<ConversationModel> _filtered(List<ConversationModel> all) {
    if (_query.isEmpty) return all;
    final q = _query.toLowerCase();
    return all.where((c) {
      final name = widget.controller.displayName(c).toLowerCase();
      return name.contains(q);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // App bar
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: Row(
            children: [
              Obx(() {
                final me = widget.controller.myUserId.value;
                return CircleAvatar(
                  radius: 20,
                  backgroundColor: Colors.grey[300],
                  child: me != null
                      ? null
                      : const Icon(Icons.person, color: Colors.grey),
                );
              }),
              const SizedBox(width: 12),
              const Expanded(
                child: Text('Chats',
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: Colors.black, letterSpacing: -0.5)),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.photo_camera_outlined, color: Colors.black, size: 26),
                splashRadius: 22,
              ),
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const NewMessageScreen())),
                icon: const Icon(Icons.edit_square, color: Colors.black, size: 24),
                splashRadius: 22,
              ),
            ],
          ),
        ),

        // Search bar
        ChatSearchBar(
          controller: _searchController,
          focusNode: _searchFocus,
          isActive: _searchActive,
          onTap: () => setState(() { _searchActive = true; }),
          onChanged: (v) => setState(() { _query = v; }),
          onCancel: () {
            setState(() { _searchActive = false; _query = ''; });
            _searchController.clear();
            _searchFocus.unfocus();
          },
        ),

        // Content
        Expanded(
          child: Obx(() {
            if (widget.controller.isLoading.value && widget.controller.conversations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = _filtered(widget.controller.conversations);

            if (list.isEmpty) {
              return Center(
                child: Text(
                  _query.isNotEmpty ? 'No results for "$_query"' : (widget.controller.error.value ?? 'No messages yet'),
                  style: const TextStyle(color: Colors.grey, fontSize: 15),
                ),
              );
            }

            return ListView.builder(
              padding: EdgeInsets.zero,
              itemCount: list.length,
              itemBuilder: (_, i) => ChatMessageTile(
                conversation: list[i],
                controller: widget.controller,
                onTap: () => Get.toNamed(AppRoutes.CHAT,
                    arguments: list[i]),
              ),
            );
          }),
        ),
      ],
    );
  }
}
