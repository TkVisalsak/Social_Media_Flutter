import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/comments_repository.dart';
import '../../feed/controllers/feed_controller.dart';

class PostDetailController extends GetxController {
  final CommentsRepository _commentsRepo;
  final PostModel? _initialPost;

  PostDetailController(this._commentsRepo, {PostModel? initialPost})
      : _initialPost = initialPost;

  late final PostModel post;

  final isLoading = false.obs;
  final error = RxnString();

  final comments = <CommentModel>[].obs;
  final replyTo = Rxn<CommentModel>();

  final inputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (_initialPost != null) {
      post = _initialPost;
    } else {
      final arg = Get.arguments;
      if (arg is PostModel) {
        post = arg;
      } else {
        // Minimal fallback; prefer passing a full PostModel as arguments.
        post = PostModel(
          id: (arg ?? '').toString(),
          user: const UserModel(id: '', email: ''),
          url: '',
          createdAt: DateTime.now(),
        );
      }
    }
    fetchComments();
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  Future<void> fetchComments() async {
    isLoading(true);
    error(null);
    final res = await _commentsRepo.getComments(post.id);
    if (res.success) {
      comments.assignAll(res.data ?? const []);
    } else {
      error(res.error);
    }
    isLoading(false);
  }

  void startReply(CommentModel c) {
    replyTo(c);
  }

  void cancelReply() {
    replyTo(null);
  }

  Future<void> send() async {
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    final parent = replyTo.value?.id;
    final res = await _commentsRepo.addComment(post.id, text: text, parentId: parent);
    if (res.success) {
      inputController.clear();
      replyTo(null);
      // Refresh so threading/order matches server
      await fetchComments();

      // Optimistically bump feed comment count if this post exists there
      if (Get.isRegistered<FeedController>()) {
        final feed = Get.find<FeedController>();
        final idx = feed.posts.indexWhere((p) => p.id == post.id);
        if (idx >= 0) {
          final old = feed.posts[idx];
          feed.posts[idx] = old.copyWith(commentsCount: old.commentsCount + 1);
          feed.posts.refresh();
        }
      }
    } else {
      Get.snackbar('Error', res.error ?? 'Failed to send comment',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> deleteComment(CommentModel c) async {
    final res = await _commentsRepo.deleteComment(c.id);
    if (res.success) {
      comments.removeWhere((x) => x.id == c.id || x.parentId == c.id);
      comments.refresh();
    } else {
      Get.snackbar('Error', res.error ?? 'Failed to delete comment',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> toggleLike() async {
    if (!Get.isRegistered<FeedController>()) return;
    await Get.find<FeedController>().toggleLike(post.id);
  }
}

