import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/message_model.dart';
import '../../../shared/widgets/story_avatar.dart';
import '../../feed/controllers/story_feed_controller.dart';
import '../../story/models/story_viewer_item.dart';
import '../../story/models/story_viewer_user.dart';
import '../../story/views/story_viewer_screen.dart';
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
        // ── App bar ──────────────────────────────────────────────
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
                    style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: Colors.black,
                        letterSpacing: -0.5)),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.photo_camera_outlined,
                    color: Colors.black, size: 26),
                splashRadius: 22,
              ),
              IconButton(
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(
                        builder: (_) => const NewMessageScreen())),
                icon: const Icon(Icons.edit_square,
                    color: Colors.black, size: 24),
                splashRadius: 22,
              ),
            ],
          ),
        ),

        // ── Search bar ───────────────────────────────────────────
        ChatSearchBar(
          controller: _searchController,
          focusNode: _searchFocus,
          isActive: _searchActive,
          onTap: () => setState(() => _searchActive = true),
          onChanged: (v) => setState(() => _query = v),
          onCancel: () {
            setState(() {
              _searchActive = false;
              _query = '';
            });
            _searchController.clear();
            _searchFocus.unfocus();
          },
        ),

        // ── Friends story bar ─────────────────────────────────────
        if (!_searchActive) const _DirectStoryBar(),

        // ── Conversation list ─────────────────────────────────────
        Expanded(
          child: Obx(() {
            if (widget.controller.isLoading.value &&
                widget.controller.conversations.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            final list = _filtered(widget.controller.conversations);

            if (list.isEmpty) {
              return Center(
                child: Text(
                  _query.isNotEmpty
                      ? 'No results for "$_query"'
                      : (widget.controller.error.value ??
                          'No messages yet'),
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
                onTap: () =>
                    Get.toNamed(AppRoutes.CHAT, arguments: list[i]),
              ),
            );
          }),
        ),
      ],
    );
  }
}

// ─── Friends story bar ─────────────────────────────────────────────────────────

class _DirectStoryBar extends StatelessWidget {
  const _DirectStoryBar();

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inHours >= 1) return '${d.inHours}h';
    if (d.inMinutes >= 1) return '${d.inMinutes}m';
    return 'now';
  }

  List<StoryViewerUser> _buildViewerUsers(StoryFeedController ctrl) {
    return ctrl.groupedByUser
        .where((g) => g.first.user.id != ctrl.myUserId)
        .map((userStories) {
          final first = userStories.first;
          final username =
              first.user.username ?? first.user.fullName ?? 'user';
          final profilePic = first.user.profilePic ?? '';
          return StoryViewerUser(
            userId: first.user.id,
            username: username,
            profileImage: profilePic,
            isNetworkImage: profilePic.startsWith('http'),
            stories: userStories
                .expand((s) => s.mediaUrl.map((m) => StoryViewerItem(
                      storyId: s.id,
                      type: m.type == 'video'
                          ? StoryViewerType.video
                          : StoryViewerType.image,
                      media: m.url,
                      isNetwork: m.url.startsWith('http'),
                      time: _timeAgo(s.createdAt),
                    )))
                .toList(),
          );
        })
        .toList()
      ..sort((a, b) {
        if (a.viewed == b.viewed) return 0;
        return a.viewed ? 1 : -1;
      });
  }

  @override
  Widget build(BuildContext context) {
    // Guard: controller must be registered (by DirectBinding)
    if (!Get.isRegistered<StoryFeedController>()) return const SizedBox();

    final ctrl = Get.find<StoryFeedController>();

    return Obx(() {
      if (ctrl.isLoading.value && ctrl.stories.isEmpty) {
        return const SizedBox(
          height: 96,
          child: Center(
            child: SizedBox(
              width: 20, height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        );
      }

      final viewerUsers = _buildViewerUsers(ctrl);
      if (viewerUsers.isEmpty) return const SizedBox();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 96,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              itemCount: viewerUsers.length,
              itemBuilder: (context, i) {
                final vu = viewerUsers[i];
                return _StoryBubble(
                  user: vu,
                  allUsers: viewerUsers,
                  index: i,
                );
              },
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
        ],
      );
    });
  }
}

// ─── Single story bubble (avatar + name) ──────────────────────────────────────

class _StoryBubble extends StatelessWidget {
  final StoryViewerUser       user;
  final List<StoryViewerUser> allUsers;
  final int                   index;

  const _StoryBubble({
    required this.user,
    required this.allUsers,
    required this.index,
  });

  void _openStory(BuildContext context) {
    if (allUsers.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StoryViewerScreen(
          users: allUsers,
          initialUserIndex: index.clamp(0, allUsers.length - 1),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _openStory(context),
      child: Padding(
        padding: const EdgeInsets.only(right: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            StoryAvatar(
              imagePath: user.profileImage.isNotEmpty
                  ? user.profileImage
                  : null,
              isNetworkImage: user.isNetworkImage,
              username: user.username,
              radius: 26,
              hasRing: true,
              isViewed: user.viewed,
            ),
            const SizedBox(height: 5),
            SizedBox(
              width: 60,
              child: Text(
                user.username,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: user.viewed
                      ? Colors.grey
                      : Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
