import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/middlewares/auth_middleware.dart';
import '../../../core/services/socket_service.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/save_model.dart';
import '../../../data/models/short_model.dart';
import '../../../data/providers/comments_provider.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/comments_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/save_repository.dart';
import '../../../data/repositories/short_repository.dart';
import '../../post_detail/controllers/post_detail_controller.dart';
import '../../post_detail/views/post_detail_view.dart';
import 'package:dio/dio.dart';

class ProfileController extends GetxController {
  final AuthRepository  _authRepo;
  final FeedRepository  _feedRepo;
  final ShortRepository _shortRepo;
  final SaveRepository  _saveRepo;

  ProfileController(this._authRepo, this._feedRepo, this._shortRepo, this._saveRepo);

  final _picker = ImagePicker();

  final isLoading        = false.obs;
  final username         = ''.obs;
  final name             = ''.obs;
  final bio              = ''.obs;
  final website          = ''.obs;
  final profilePic       = ''.obs;
  final pickedImagePath  = RxnString();
  final postsCount       = 0.obs;
  final followersCount   = 0.obs;
  final followingCount   = 0.obs;

  final myPosts          = <PostModel>[].obs;
  final myShorts         = <ShortModel>[].obs;
  final likedPosts       = <PostModel>[].obs;
  final savedPosts       = <PostModel>[].obs;
  final isContentLoading = false.obs;

  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    isLoading(true);
    final user = await LocalStorage.user;
    if (user != null) {
      _userId = user.id;
      username(user.username ?? user.email.split('@').first);
      name(user.fullName ?? user.username ?? '');
      bio(user.bio ?? '');
      profilePic(user.profilePic ?? '');
    }
    isLoading(false);
    if (_userId != null) _loadContent();
  }

  Future<void> _loadContent() async {
    isContentLoading(true);

    // Fetch posts, shorts, liked, and saved concurrently
    final postsF  = _feedRepo.getUserPosts(_userId!);
    final shortsF = _shortRepo.getByUser(_userId!);
    final likedF  = _feedRepo.getLikedPosts(_userId!);
    final savedF  = _saveRepo.getSavedByUser(_userId!);

    final postsRes  = await postsF;
    final shortsRes = await shortsF;
    final likedRes  = await likedF;
    final savedRes  = await savedF;

    if (postsRes.success && postsRes.data != null) {
      myPosts.assignAll(postsRes.data!);
      postsCount(postsRes.data!.length);
    }
    if (shortsRes.success && shortsRes.data != null) {
      myShorts.assignAll(shortsRes.data!);
    }
    if (likedRes.success && likedRes.data != null) {
      likedPosts.assignAll(likedRes.data!);
    }
    if (savedRes.success && savedRes.data != null) {
      // SaveModel only has contentId — fetch each saved feed post individually
      final saves = savedRes.data!
          .where((s) => s.contentType == SaveContentType.feed)
          .toList();
      final fetched = await Future.wait(
        saves.map((s) => _feedRepo.getPostById(s.contentId)),
      );
      final posts = fetched
          .where((r) => r.success && r.data != null)
          .map((r) => r.data!)
          .toList();
      savedPosts.assignAll(posts);
    }

    isContentLoading(false);
  }

  String? get userId => _userId;

  /// Open a post in the detail sheet (same pattern as FeedController).
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

  Future<void> updateProfile() async {
    isLoading(true);
    if (pickedImagePath.value != null) {
      final res = await _authRepo.uploadProfilePic(pickedImagePath.value!);
      if (res.success && res.data != null) {
        profilePic(res.data!.profilePic ?? '');
        pickedImagePath(null);
      }
    }
    isLoading(false);
    Get.back();
  }

  Future<void> pickProfileImage() async {
    final picked = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) {
      pickedImagePath(picked.path);
      profilePic(picked.path); // preview locally
    }
  }

  Future<void> logout() async {
    await _authRepo.logout();
    AuthSession.setLoggedIn(false);
    Get.find<SocketService>().disconnect();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
