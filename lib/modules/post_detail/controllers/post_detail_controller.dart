import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/comment_model.dart';
import '../../../data/models/post_model.dart';
import '../../../data/repositories/comments_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../feed/controllers/feed_controller.dart';

class PostDetailController extends GetxController {
  PostDetailController(this._commentsRepo, this._feedRepo, {PostModel? initialPost})
      : _initialPost = initialPost;

  final CommentsRepository _commentsRepo;
  final FeedRepository     _feedRepo;
  final PostModel?         _initialPost;

  final post          = Rxn<PostModel>();
  final isLoadingPost = false.obs;
  final isLoading     = false.obs;
  final error         = RxnString();

  final comments        = <CommentModel>[].obs;
  final replyTo         = Rxn<CommentModel>();
  final inputController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    if (_initialPost != null) {
      post.value = _initialPost;
      fetchComments();
      return;
    }

    final arg = Get.arguments;
    if (arg is PostModel) {
      post.value = arg;
      fetchComments();
    } else {
      // String postId — came from deep link or route param
      final postId = (arg ?? Get.parameters['id'] ?? '').toString();
      _fetchPostById(postId);
    }
  }

  @override
  void onClose() {
    inputController.dispose();
    super.onClose();
  }

  Future<void> _fetchPostById(String id) async {
    if (id.isEmpty) { error('No post ID'); return; }
    isLoadingPost(true);
    final res = await _feedRepo.getPostById(id);
    isLoadingPost(false);
    if (res.success && res.data != null) {
      post.value = res.data;
      fetchComments();
    } else {
      error(res.error ?? 'Post not found');
    }
  }

  Future<void> fetchComments() async {
    final p = post.value;
    if (p == null) return;
    isLoading(true);
    error(null);
    final res = await _commentsRepo.getComments(p.id);
    if (res.success) {
      comments.assignAll(res.data ?? const []);
    } else {
      error(res.error);
    }
    isLoading(false);
  }

  void startReply(CommentModel c) => replyTo(c);
  void cancelReply()              => replyTo(null);

  Future<void> send() async {
    final p = post.value;
    if (p == null) return;
    final text = inputController.text.trim();
    if (text.isEmpty) return;

    final parent = replyTo.value?.id;
    final res = await _commentsRepo.addComment(p.id, text: text, parentId: parent);
    if (res.success) {
      inputController.clear();
      replyTo(null);
      await fetchComments();

      if (Get.isRegistered<FeedController>()) {
        final feed = Get.find<FeedController>();
        final idx = feed.posts.indexWhere((x) => x.id == p.id);
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
}
