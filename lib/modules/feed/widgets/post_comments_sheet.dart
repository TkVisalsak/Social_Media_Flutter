import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/comments_repository.dart';

class PostCommentsSheet extends StatefulWidget {
  final String postId;
  final VoidCallback? onCommented;

  const PostCommentsSheet({
    super.key,
    required this.postId,
    this.onCommented,
  });

  @override
  State<PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<PostCommentsSheet> {
  final _textCtrl     = TextEditingController();
  final _scrollCtrl   = ScrollController();
  final _comments     = <CommentModel>[];

  bool    _isLoading  = true;
  bool    _isSending  = false;
  String? _error;
  String? _myUserId;

  CommentsRepository get _repo => Get.find<CommentsRepository>();

  @override
  void initState() {
    super.initState();
    _init();
  }

  @override
  void dispose() {
    _textCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final me = await LocalStorage.user;
    _myUserId = me?.id;
    await _fetchComments();
  }

  Future<void> _fetchComments() async {
    setState(() { _isLoading = true; _error = null; });
    final res = await _repo.getComments(widget.postId);
    if (!mounted) return;
    if (res.success) {
      setState(() { _comments
        ..clear()
        ..addAll(res.data ?? []); });
    } else {
      setState(() => _error = res.error ?? 'Failed to load comments');
    }
    setState(() => _isLoading = false);
  }

  Future<void> _submit() async {
    final text = _textCtrl.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() => _isSending = true);
    final res = await _repo.addComment(widget.postId, text: text);
    if (!mounted) return;

    if (res.success && res.data != null) {
      _textCtrl.clear();
      FocusScope.of(context).unfocus();
      setState(() => _comments.insert(0, res.data!));
      widget.onCommented?.call();
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
          TextButton(onPressed: () => Navigator.pop(context, false),
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
    } else {
      Get.snackbar('Error', res.error ?? 'Failed to delete',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollCtrl) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // ── Handle + header ──────────────────────
            _SheetHandle(),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '${_comments.length} Comment${_comments.length == 1 ? '' : 's'}',
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const Divider(height: 1),

            // ── Body ─────────────────────────────────
            Expanded(
              child: _buildBody(scrollCtrl),
            ),

            // ── Input ────────────────────────────────
            _CommentInput(
              controller: _textCtrl,
              isSending: _isSending,
              onSubmit: _submit,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(ScrollController scrollCtrl) {
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
      controller: scrollCtrl,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: _comments.length,
      separatorBuilder: (_, __) => const SizedBox(height: 4),
      itemBuilder: (_, i) => _CommentTile(
        comment: _comments[i],
        myUserId: _myUserId,
        onDelete: _deleteComment,
      ),
    );
  }
}

// ─── Comment tile ─────────────────────────────────────────────────────────────

class _CommentTile extends StatefulWidget {
  final CommentModel comment;
  final String?      myUserId;
  final void Function(CommentModel) onDelete;

  const _CommentTile({
    required this.comment,
    required this.myUserId,
    required this.onDelete,
  });

  @override
  State<_CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<_CommentTile> {
  bool _liked  = false;
  int  _likes  = 0;

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
    final c       = widget.comment;
    final isOwn   = c.user.id == widget.myUserId;
    final username = c.user.username ?? c.user.fullName ?? 'user';

    return GestureDetector(
      onLongPress: isOwn ? () => widget.onDelete(c) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Avatar(user: c.user, radius: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: const TextStyle(color: Colors.black, fontSize: 14),
                      children: [
                        TextSpan(
                          text: '$username ',
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: c.text),
                      ],
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
                        Text('${c.replyCount} repl${c.replyCount == 1 ? 'y' : 'ies'}',
                            style: const TextStyle(
                                color: Colors.grey, fontSize: 12,
                                fontWeight: FontWeight.w600)),
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

// ─── Shared small widgets ─────────────────────────────────────────────────────

class _Avatar extends StatelessWidget {
  final UserModel user;
  final double    radius;
  const _Avatar({required this.user, required this.radius});

  @override
  Widget build(BuildContext context) {
    final pic = user.profilePic;
    final initial =
        (user.username ?? user.fullName ?? '?')[0].toUpperCase();
    return CircleAvatar(
      radius: radius,
      backgroundColor: Colors.grey[200],
      backgroundImage:
          (pic != null && pic.isNotEmpty) ? NetworkImage(pic) : null,
      child: (pic == null || pic.isEmpty)
          ? Text(initial,
              style: TextStyle(
                  fontSize: radius * 0.8, fontWeight: FontWeight.w600))
          : null,
    );
  }
}

class _SheetHandle extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(top: 12, bottom: 10),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2)),
      );
}

class _CommentInput extends StatelessWidget {
  final TextEditingController controller;
  final bool        isSending;
  final VoidCallback onSubmit;

  const _CommentInput({
    required this.controller,
    required this.isSending,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16, right: 16, bottom: 8,
          top: 8 + MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: controller,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSubmit(),
                  decoration: const InputDecoration(
                    hintText: 'Add a comment...',
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 10),
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
