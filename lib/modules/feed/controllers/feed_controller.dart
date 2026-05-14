import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/comments_provider.dart';
import '../../../data/providers/local_storage.dart';
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

    final old = posts[index];
    // Optimistic update
    posts[index] = old.copyWith(
      isLiked:    !old.isLiked,
      likesCount: old.isLiked ? old.likesCount - 1 : old.likesCount + 1,
    );
    posts.refresh();

    final res = await _repo.toggleLike(postId, wasLiked: old.isLiked);
    if (!res.success) {
      posts[index] = old;
      posts.refresh();
    }
  }

  // ── Create post ──────────────────────────────────
  final isCreating = false.obs;

  Future<bool> createPost({
    String? caption,
    String? imagePath,
    String visibility = 'public',
    String? location,
  }) async {
    isCreating(true);
    final me = await LocalStorage.user;
    final res = await _repo.createPost(
      caption: caption,
      filePath: imagePath,
      visibility: visibility,
      location: location,
    );
    isCreating(false);

    if (res.success && res.data != null) {
      // Backend returns post without populated user — inject from LocalStorage.
      final post = res.data!.copyWith(
        user: me ?? const UserModel(id: '', email: ''),
      );
      posts.insert(0, post);
      posts.refresh();
      return true;
    }

    Get.snackbar('Error', res.error ?? 'Failed to create post',
        snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  // ── Comment count ────────────────────────────────
  void incrementCommentCount(String postId) {
    final i = posts.indexWhere((p) => p.id == postId);
    if (i < 0) return;
    posts[i] = posts[i].copyWith(commentsCount: posts[i].commentsCount + 1);
    posts.refresh();
  }

  // ── Repost ───────────────────────────────────────
  void toggleRepost(String postId, {required bool reposted}) {
    final i = posts.indexWhere((p) => p.id == postId);
    if (i < 0) return;
    final delta = reposted ? 1 : -1;
    posts[i] = posts[i].copyWith(sharesCount: posts[i].sharesCount + delta);
    posts.refresh();
  }

  // ── Share count ───────────────────────────────────
  void incrementShareCount(String postId) {
    final i = posts.indexWhere((p) => p.id == postId);
    if (i < 0) return;
    posts[i] = posts[i].copyWith(sharesCount: posts[i].sharesCount + 1);
    posts.refresh();
    // fire and forget
    _repo.sharePost(postId);
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