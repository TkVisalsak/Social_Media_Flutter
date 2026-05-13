import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/post_model.dart';
import '../../../data/providers/comments_provider.dart';
import '../../../data/repositories/comments_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../app/routes/app_routes.dart';
import '../../post_detail/controllers/post_detail_controller.dart';
import '../../post_detail/views/post_detail_view.dart';
import '../widgets/feed_create_flow.dart';

class FeedController extends GetxController {
  final FeedRepository _repo;
  FeedController(this._repo);

  // ── State ────────────────────────────────────────
  final posts     = <PostModel>[].obs;
  final isLoading = false.obs;
  final hasMore   = true.obs;
  final error     = RxnString();
  int _page       = 1;

  // ── Lifecycle ────────────────────────────────────
  @override
  void onInit() {
    super.onInit();
    fetchFeed();
  }

  // ── Fetch ────────────────────────────────────────
  Future<void> fetchFeed({bool refresh = false}) async {
    if (isLoading.value) return;
    if (!hasMore.value && !refresh) return;

    if (refresh) {
      _page = 1;
      hasMore(true);
      posts.clear();
    }

    isLoading(true);
    error(null);

    final res = await _repo.getFeed(_page);
    print('res: ${res.data}');
    if (res.success) {
      final newPosts = res.data!;
      posts.addAll(newPosts);
      if (newPosts.isEmpty || newPosts.length < 20) hasMore(false);
      _page++;
    } else {
      error(res.error);
      Get.snackbar(
        'Error',
        res.error ?? 'Failed to load feed',
        snackPosition: SnackPosition.BOTTOM,
      );
    }

    isLoading(false);
  }

  // ── Like ─────────────────────────────────────────
  Future<void> toggleLike(String postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    // Optimistic update
    final old = posts[index];
    posts[index] = old.copyWith(
      isLiked:    !old.isLiked,
      likesCount: old.isLiked ? old.likesCount - 1 : old.likesCount + 1,
    );
    posts.refresh();

    final res = await _repo.toggleLike(postId, wasLiked: old.isLiked);
    if (!res.success) {
      // Rollback on failure
      posts[index] = old;
      posts.refresh();
      return;
    }

    // Sync count from server (if endpoint exists)
    final countRes = await _repo.getLikesCount(postId);
    if (countRes.success) {
      final current = posts[index];
      posts[index] = current.copyWith(likesCount: countRes.data ?? current.likesCount);
      posts.refresh();
    }
  }

  // ── Save ─────────────────────────────────────────
  Future<void> toggleSave(String postId) async {
    final index = posts.indexWhere((p) => p.id == postId);
    if (index < 0) return;

    final old = posts[index];
    posts[index] = old.copyWith(isSaved: !old.isSaved);
    posts.refresh();

    final res = await _repo.savePost(postId);
    if (!res.success) {
      posts[index] = old;
      posts.refresh();
    }
  }

  // ── Navigation ────────────────────────────────────
  void openStory(String userId) =>
      Get.toNamed(AppRoutes.STORY, arguments: userId);

  Future<void> openPostDetail(PostModel post) async {
    if (!Get.isRegistered<CommentsRepository>()) {
      Get.lazyPut<CommentsProvider>(() => CommentsProvider(Get.find<Dio>()));
      Get.lazyPut<CommentsRepository>(
        () => CommentsRepositoryImpl(Get.find<CommentsProvider>()),
      );
    }
    if (Get.isRegistered<PostDetailController>()) {
      Get.delete<PostDetailController>(force: true);
    }
    Get.put(
      PostDetailController(
        Get.find<CommentsRepository>(),
        Get.find<FeedRepository>(),
        initialPost: post,
      ),
    );

    final ctx = Get.context;
    if (ctx == null) return;

    await showModalBottomSheet<void>(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final h = MediaQuery.sizeOf(sheetContext).height * 0.72;
        final inset = MediaQuery.viewInsetsOf(sheetContext).bottom;
        return Padding(
          padding: EdgeInsets.only(bottom: inset),
          child: Container(
            height: h,
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            clipBehavior: Clip.antiAlias,
            child: const PostDetailView.sheet(),
          ),
        );
      },
    );

    if (Get.isRegistered<PostDetailController>()) {
      Get.delete<PostDetailController>(force: true);
    }
  }

  void openNotifications() =>
      Get.toNamed(AppRoutes.NOTIFICATIONS);

  void openDirect() =>
      Get.toNamed(AppRoutes.DIRECT);

  void openPlusMenu(BuildContext context) =>
      FeedCreateFlow.showOptions(context);

  void openCreatePost() {
    final ctx = Get.context;
    if (ctx != null) FeedCreateFlow.showPostOverlay(ctx);
  }
}