import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/post_model.dart';
import '../../../shared/widgets/social_action_buttons.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailView extends GetView<PostDetailController> {
  const PostDetailView({super.key}) : isSheet = false;
  const PostDetailView.sheet({super.key}) : isSheet = true;

  final bool isSheet;

  @override
  Widget build(BuildContext context) {
    final body = Column(
      children: [
        if (isSheet) const _CommentsSheetHeader(),

        // ── Post content (route mode only) ──────────────
        if (!isSheet)
          Obx(() {
            if (controller.isLoadingPost.value) {
              return const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final p = controller.post.value;
            if (p == null) return const SizedBox.shrink();
            return _PostSummary(post: p);
          }),

        // ── Action row (route mode only) ─────────────────
        if (!isSheet)
          Obx(() {
            final ctrl = Get.find<PostDetailController>();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: Row(
                children: [
                  LikeButton(
                    isLiked: ctrl.isLiked.value,
                    likeCount: ctrl.likesCount.value,
                    onTap: (_) => ctrl.toggleLike(),
                    size: 26,
                    likedColor: const Color(0xFFF02849),
                    unlikedColor: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () {}, // already on comments
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline_rounded, size: 26),
                        const SizedBox(width: 5),
                        Obx(() => Text(
                          '${Get.find<PostDetailController>().comments.length}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        )),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => ctrl.incrementShareCount(),
                    child: Row(
                      children: [
                        Transform.scale(scaleX: -1, child: const Icon(Icons.reply_rounded, size: 26)),
                        const SizedBox(width: 5),
                        Obx(() => Text(
                          '${Get.find<PostDetailController>().sharesCount.value}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        )),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Obx(() => GestureDetector(
                    onTap: () => Get.find<PostDetailController>().toggleSave(),
                    child: Icon(
                      Get.find<PostDetailController>().isSaved.value
                          ? Icons.bookmark
                          : Icons.bookmark_outline,
                      size: 25,
                      color: Get.find<PostDetailController>().isSaved.value
                          ? const Color(0xFF3797F0)
                          : Colors.black,
                    ),
                  )),
                ],
              ),
            );
          }),

        // ── Comments list ────────────────────────────────
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value && controller.comments.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.error.value != null && controller.comments.isEmpty) {
              return Center(
                child: Text(controller.error.value!,
                    style: const TextStyle(color: Colors.grey)),
              );
            }

            final all     = controller.comments.toList(growable: false);
            final parents = all.where((c) => c.parentId == null).toList();
            final repliesByParent = <String, List<dynamic>>{};
            for (final c in all.where((c) => c.parentId != null)) {
              repliesByParent.putIfAbsent(c.parentId!, () => []).add(c);
            }

            if (parents.isEmpty) {
              return const Center(
                child: Text('No comments yet.',
                    style: TextStyle(color: Colors.grey, fontSize: 15)),
              );
            }

            return RefreshIndicator(
              onRefresh: controller.fetchComments,
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: parents.length,
                itemBuilder: (_, i) {
                  final p = parents[i];
                  final replies = (repliesByParent[p.id] ?? const []).cast();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _CommentTile(
                        username: p.user.username ?? p.user.fullName ?? 'User',
                        text: p.text,
                        onReply: () => controller.startReply(p),
                        onDelete: () => controller.deleteComment(p),
                      ),
                      for (final r in replies)
                        Padding(
                          padding: const EdgeInsets.only(left: 34),
                          child: _CommentTile(
                            username: r.user.username ?? r.user.fullName ?? 'User',
                            text: r.text,
                            isReply: true,
                            onReply: () => controller.startReply(p),
                            onDelete: () => controller.deleteComment(r),
                          ),
                        ),
                    ],
                  );
                },
              ),
            );
          }),
        ),

        // ── Reply banner ─────────────────────────────────
        Obx(() {
          final replying = controller.replyTo.value;
          if (replying == null) return const SizedBox.shrink();
          final name = replying.user.username ?? replying.user.fullName ?? 'User';
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: Color(0xFFE6E7EA))),
              color: Color(0xFFF7F7F8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text('Replying to $name',
                      style: const TextStyle(
                          color: Colors.black87, fontWeight: FontWeight.w600)),
                ),
                TextButton(
                    onPressed: controller.cancelReply,
                    child: const Text('Cancel')),
              ],
            ),
          );
        }),

        // ── Comment input ────────────────────────────────
        SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller.inputController,
                    decoration: InputDecoration(
                      hintText: 'Write a comment…',
                      filled: true,
                      fillColor: const Color(0xFFF5F6F7),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.send(),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  onPressed: controller.send,
                  icon: const Icon(Icons.send, color: Color(0xFF4361EE)),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (isSheet) return Material(color: Colors.white, child: body);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Post',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: body,
    );
  }
}

// ─── Post summary shown at the top of the detail route ───────────────────────

class _PostSummary extends StatelessWidget {
  final PostModel post;
  const _PostSummary({required this.post});

  @override
  Widget build(BuildContext context) {
    final username   = post.user.username ?? post.user.fullName ?? 'user';
    final profilePic = post.user.profilePic;
    final images     = post.imageUrls;
    final caption    = post.caption ?? '';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: profilePic != null ? NetworkImage(profilePic) : null,
                child: profilePic == null
                    ? Text(username.isNotEmpty ? username[0].toUpperCase() : '?',
                        style: const TextStyle(fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 10),
              Text(username,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 14)),
            ],
          ),
        ),

        // Images
        if (images.isNotEmpty)
          _ImageSlider(images: images),

        // Caption
        if (caption.isNotEmpty)
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 0),
            child: RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black, fontSize: 14),
                children: [
                  TextSpan(text: '$username ',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextSpan(text: caption),
                ],
              ),
            ),
          ),

        const Divider(height: 24),
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Text('Comments',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
        ),
      ],
    );
  }
}

class _ImageSlider extends StatefulWidget {
  final List<String> images;
  const _ImageSlider({required this.images});

  @override
  State<_ImageSlider> createState() => _ImageSliderState();
}

class _ImageSliderState extends State<_ImageSlider> {
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        SizedBox(
          height: 300,
          child: PageView.builder(
            itemCount: widget.images.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (_, i) => Image.network(
              widget.images[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, _, _) =>
                  const Center(child: Icon(Icons.broken_image, size: 60, color: Colors.grey)),
            ),
          ),
        ),
        if (widget.images.length > 1)
          Positioned(
            bottom: 10,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(widget.images.length, (i) {
                final active = i == _page;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: active ? 18 : 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: active ? Colors.white : Colors.white54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                );
              }),
            ),
          ),
      ],
    );
  }
}

// ─── Comments sheet header ────────────────────────────────────────────────────

class _CommentsSheetHeader extends StatelessWidget {
  const _CommentsSheetHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 8),
        Center(
          child: Container(
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
        ),
        const SizedBox(height: 8),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              const SizedBox(width: 40),
              const Expanded(
                child: Text('Comments',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: Colors.black87),
                onPressed: () => Get.back(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ─── Comment tile ─────────────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final String username;
  final String text;
  final bool isReply;
  final VoidCallback onReply;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.username,
    required this.text,
    required this.onReply,
    required this.onDelete,
    this.isReply = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 8, 12, isReply ? 4 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: const Color(0xFF4361EE),
            child: Text(
              username.isNotEmpty ? username[0].toUpperCase() : '?',
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F7),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black87),
                      children: [
                        TextSpan(text: username,
                            style: const TextStyle(
                                fontWeight: FontWeight.w700)),
                        TextSpan(text: '  $text'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    TextButton(
                      onPressed: onReply,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Reply'),
                    ),
                    TextButton(
                      onPressed: onDelete,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
