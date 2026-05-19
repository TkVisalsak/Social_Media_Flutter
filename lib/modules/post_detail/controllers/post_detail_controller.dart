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

  // Reactive interaction state — mirrors the post's initial values
  late final isLiked     = false.obs;
  late final isSaved     = false.obs;
  late final likesCount  = 0.obs;
  late final sharesCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    if (_initialPost != null) {
      post.value = _initialPost;
      isLiked.value     = _initialPost.isLiked;
      isSaved.value     = _initialPost.isSaved;
      likesCount.value  = _initialPost.likesCount;
      sharesCount.value = _initialPost.sharesCount;
      fetchComments();
      return;
    }

    final arg = Get.arguments;
    if (arg is PostModel) {
      post.value = arg;
      isLiked.value     = arg.isLiked;
      isSaved.value     = arg.isSaved;
      likesCount.value  = arg.likesCount;
      sharesCount.value = arg.sharesCount;
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
      isLiked.value     = res.data!.isLiked;
      isSaved.value     = res.data!.isSaved;
      likesCount.value  = res.data!.likesCount;
      sharesCount.value = res.data!.sharesCount;
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

  Future<void> toggleLike() async {
    final wasLiked = isLiked.value;
    isLiked.value = !wasLiked;
    likesCount.value += wasLiked ? -1 : 1;
    final res = await _feedRepo.toggleLike(post.value!.id, wasLiked: wasLiked);
    if (!res.success) {
      isLiked.value = wasLiked;
      likesCount.value += wasLiked ? 1 : -1;
    } else {
      // Sync updated like state back to FeedController without re-calling the API.
      if (Get.isRegistered<FeedController>()) {
        final fc = Get.find<FeedController>();
        final idx = fc.posts.indexWhere((p) => p.id == post.value!.id);
        if (idx >= 0) {
          fc.posts[idx] = fc.posts[idx].copyWith(
            isLiked: isLiked.value,
            likesCount: likesCount.value,
          );
          fc.posts.refresh();
        }
      }
    }
  }

  Future<void> toggleSave() async {
    final wasSaved = isSaved.value;
    isSaved.value = !wasSaved;
    final res = wasSaved
        ? await _feedRepo.unsavePost(post.value!.id)
        : await _feedRepo.savePost(post.value!.id);
    if (!res.success) {
      isSaved.value = wasSaved;
    } else {
      // Sync updated save state back to FeedController without re-calling the API.
      if (Get.isRegistered<FeedController>()) {
        final fc = Get.find<FeedController>();
        final idx = fc.posts.indexWhere((p) => p.id == post.value!.id);
        if (idx >= 0) {
          fc.posts[idx] = fc.posts[idx].copyWith(isSaved: isSaved.value);
          fc.posts.refresh();
        }
      }
    }
  }

  Future<void> incrementShareCount() async {
    sharesCount.value++;
    await _feedRepo.sharePost(post.value!.id);
  }
}
