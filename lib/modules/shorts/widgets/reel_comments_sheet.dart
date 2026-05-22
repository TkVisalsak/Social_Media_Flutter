import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/comment_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/short_repository.dart';
import '../controllers/shorts_controller.dart';

class ReelCommentsSheet extends StatefulWidget {
  final String shortId;
  final int    commentCount;

  const ReelCommentsSheet({
    super.key,
    required this.shortId,
    required this.commentCount,
  });

  @override
  State<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends State<ReelCommentsSheet> {
  final _textCtrl   = TextEditingController();
  final _comments   = <CommentModel>[];

  bool    _isLoading = true;
  bool    _isSending = false;
  String? _error;
  String? _myUserId;

  ShortRepository get _repo => Get.find<ShortRepository>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final me = await LocalStorage.user;
    _myUserId = me?.id;
    await _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() { _isLoading = true; _error = null; });
    final res = await _repo.getComments(widget.shortId);
    if (!mounted) return;
    if (res.success) {
      setState(() {
        _comments
          ..clear()
          ..addAll(res.data ?? []);
      });
    } else {
      setState(() => _error = res.error ?? 'Failed to load comments');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submit() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final res = await _repo.addComment(widget.shortId, text: text);
    if (!mounted) return;

    if (res.success && res.data != null) {
      _textCtrl.clear();
      FocusScope.of(context).unfocus();
      setState(() => _comments.insert(0, res.data!));
      try {
        Get.find<ShortsController>().incrementCommentCount(widget.shortId);
      } catch (_) {}
    } else {
      Get.snackbar('Error', res.error ?? 'Failed to post comment',
          snackPosition: SnackPosition.BOTTOM);
    }
    setState(() => _isSending = false);
  }

  Future<void> _deleteComment(CommentModel c) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete comment?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete',
                style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    final res = await _repo.deleteComment(c.id);
    if (!mounted) return;
    if (res.success) {
      setState(() => _comments.removeWhere((x) => x.id == c.id));
      try {
        // Backend decrements commentCount — sync Flutter state too
        final ctrl = Get.find<ShortsController>();
        final i = ctrl.shorts.indexWhere((s) => s.id == widget.shortId);
        if (i >= 0) {
          ctrl.shorts[i] = ctrl.shorts[i].copyWith(
            commentCount: (ctrl.shorts[i].commentCount - 1).clamp(0, 999999),
          );
        }
      } catch (_) {}
    } else {
      Get.snackbar('Error', res.error ?? 'Failed to delete',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    final total = _comments.isEmpty && _isLoading
        ? widget.commentCount
        : _comments.length;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // ── Handle + header ──────────────────────
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 10),
            width: 40, height: 4,
            decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2)),
          ),
          Text(
            '$total Comment${total == 1 ? '' : 's'}',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const Divider(height: 16),

          // ── Body ─────────────────────────────────
          Expanded(child: _buildBody()),

          // ── Input ────────────────────────────────
          _ReelCommentInput(
            controller: _textCtrl,
            isSending: _isSending,
            onSubmit: _submit,
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 12),
            TextButton(onPressed: _fetchComments, child: const Text('Retry')),
          ],
        ),
      );
    }
    if (_comments.isEmpty) {
      return const Center(
        child: Text('No comments yet. Be the first!',
            style: TextStyle(color: Colors.grey)),
      );
    }
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, i) => _ReelCommentTile(
        comment: _comments[i],
        myUserId: _myUserId,
        onDelete: _deleteComment,
      ),
    );
  }
}

// ─── Comment tile ─────────────────────────────────────────────────────────────

class _ReelCommentTile extends StatefulWidget {
  final CommentModel comment;
  final String?      myUserId;
  final void Function(CommentModel) onDelete;

  const _ReelCommentTile({
    required this.comment,
    required this.myUserId,
    required this.onDelete,
  });

  @override
  State<_ReelCommentTile> createState() => _ReelCommentTileState();
}

class _ReelCommentTileState extends State<_ReelCommentTile> {
  bool _liked = false;
  int  _likes = 0;

  @override
  void initState() {
    super.initState();
    _liked = widget.comment.isLiked;
    _likes = widget.comment.likeCount;
  }

  static String _timeAgo(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inDays >= 1)    return '${d.inDays}d';
    if (d.inHours >= 1)   return '${d.inHours}h';
    if (d.inMinutes >= 1) return '${d.inMinutes}m';
    return 'now';
  }

  @override
  Widget build(BuildContext context) {
    final c        = widget.comment;
    final isOwn    = c.user.id == widget.myUserId;
    final username = c.user.username ?? c.user.fullName ?? 'user';
    final pic      = c.user.profilePic;

    void openProfile() {
      if (isOwn) {
        Get.back();
        Get.toNamed(AppRoutes.PROFILE);
      } else {
        Get.toNamed(AppRoutes.OTHER_PROFILE, arguments: c.user);
      }
    }

    return GestureDetector(
      onLongPress: isOwn ? () => widget.onDelete(c) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: openProfile,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.grey[200],
                backgroundImage: (pic != null && pic.isNotEmpty)
                    ? NetworkImage(pic)
                    : null,
                child: (pic == null || pic.isEmpty)
                    ? Text(username[0].toUpperCase(),
                        style: const TextStyle(fontSize: 14))
                    : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: openProfile,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                            color: Colors.black, fontSize: 14),
                        children: [
                          TextSpan(
                              text: '$username ',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w700)),
                          TextSpan(text: c.text),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(_timeAgo(c.createdAt),
                          style: TextStyle(
                              color: Colors.grey.shade500, fontSize: 12)),
                      if (c.replyCount > 0) ...[
                        const SizedBox(width: 12),
                        Text(
                          '${c.replyCount} repl${c.replyCount == 1 ? 'y' : 'ies'}',
                          style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                      if (isOwn) ...[
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => widget.onDelete(c),
                          child: const Text('Delete',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => setState(() {
                _liked = !_liked;
                _likes += _liked ? 1 : -1;
              }),
              child: Column(
                children: [
                  Icon(
                    _liked ? Icons.favorite : Icons.favorite_border,
                    size: 16,
                    color: _liked ? Colors.red : Colors.grey,
                  ),
                  if (_likes > 0)
                    Text('$_likes',
                        style: const TextStyle(
                            fontSize: 11, color: Colors.grey)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Input bar ────────────────────────────────────────────────────────────────

class _ReelCommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool        isSending;
  final VoidCallback onSubmit;

  const _ReelCommentInput({
    required this.controller,
    required this.isSending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(24)),
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSubmit(),
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: isSending ? null : onSubmit,
              child: isSending
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Color(0xFF3797F0)))
                  : const Text('Post',
                      style: TextStyle(
                          color: Color(0xFF3797F0),
                          fontWeight: FontWeight.w700)),
            ),
          ],
        ),
      ),
    );
  }
}
