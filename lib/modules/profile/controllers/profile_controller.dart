import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/middlewares/auth_middleware.dart';
import '../../../core/services/socket_service.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/repost_model.dart';
import '../../../data/models/save_model.dart';
import '../../../data/models/short_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/repost_repository.dart';
import '../../../data/repositories/save_repository.dart';
import '../../../data/repositories/short_repository.dart';

class ProfileController extends GetxController {
  final AuthRepository   _authRepo;
  final FeedRepository   _feedRepo;
  final ShortRepository  _shortRepo;
  final SaveRepository   _saveRepo;
  final FollowRepository _followRepo;
  final RepostRepository _repostRepo;

  ProfileController(this._authRepo, this._feedRepo, this._shortRepo, this._saveRepo, this._followRepo, this._repostRepo);

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
  final myReposts        = <RepostModel>[].obs;
  // contentId → PostModel for feed-type reposts (populated in _loadContent)
  final repostPostCache  = <String, PostModel>{};
  final likedPosts       = <PostModel>[].obs;
  final likedShorts      = <ShortModel>[].obs;
  final savedPosts       = <PostModel>[].obs;
  final savedShorts      = <ShortModel>[].obs;
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

  Future<void> reload() async {
    if (_userId != null) _loadContent();
  }

  Future<void> _loadContent() async {
    isContentLoading(true);
    try {
    // Fetch all data concurrently
    final postsF      = _feedRepo.getUserPosts(_userId!);
    final shortsF     = _shortRepo.getByUser(_userId!);
    final repostsF    = _repostRepo.getUserReposts(_userId!);
    final likedPostsF = _feedRepo.getLikedPosts(_userId!);
    final likedShortF = _shortRepo.getLikedByUser(_userId!);
    final savedF      = _saveRepo.getSavedByUser(_userId!);
    final followersF  = _followRepo.getFollowers(_userId!);
    final followingF  = _followRepo.getFollowing(_userId!);

    final postsRes      = await postsF;
    final shortsRes     = await shortsF;
    final repostsRes    = await repostsF;
    final likedRes      = await likedPostsF;
    final likedShortRes = await likedShortF;
    final savedRes      = await savedF;
    final followersRes  = await followersF;
    final followingRes  = await followingF;

    if (postsRes.success && postsRes.data != null) {
      myPosts.assignAll(postsRes.data!);
      postsCount(postsRes.data!.length);
    }
    if (shortsRes.success && shortsRes.data != null) {
      myShorts.assignAll(shortsRes.data!);
    }
    if (repostsRes.success && repostsRes.data != null) {
      myReposts.assignAll(repostsRes.data!);
      // Pre-fetch actual PostModel for each feed-type repost so the tab can
      // show the post image and like/save buttons without per-tile requests.
      final feedReposts = repostsRes.data!
          .where((r) => r.contentType == RepostContentType.feed)
          .toList();
      if (feedReposts.isNotEmpty) {
        final fetched = await Future.wait(
          feedReposts.map((r) => _feedRepo.getPostById(r.contentId)),
        );
        repostPostCache.clear();
        for (int i = 0; i < feedReposts.length; i++) {
          final result = fetched[i];
          if (result.success && result.data != null) {
            repostPostCache[feedReposts[i].contentId] = result.data!;
          }
        }
      }
    }
    if (likedRes.success && likedRes.data != null) {
      likedPosts.assignAll(likedRes.data!);
    }
    if (likedShortRes.success && likedShortRes.data != null) {
      likedShorts.assignAll(likedShortRes.data!);
    }
    if (savedRes.success && savedRes.data != null) {
      // Separate feed and short saves
      final feedSaves  = savedRes.data!.where((s) => s.contentType == SaveContentType.feed).toList();
      final shortSaves = savedRes.data!.where((s) => s.contentType == SaveContentType.short).toList();

      // Fetch saved feed posts
      final fetchedPosts = await Future.wait(
        feedSaves.map((s) => _feedRepo.getPostById(s.contentId)),
      );
      savedPosts.assignAll(fetchedPosts
          .where((r) => r.success && r.data != null)
          .map((r) => r.data!));

      // Fetch saved shorts by ID
      final fetchedShorts = await Future.wait(
        shortSaves.map((s) => _shortRepo.getById(s.contentId)),
      );
      savedShorts.assignAll(fetchedShorts
          .where((r) => r.success && r.data != null)
          .map((r) => r.data!));
    }

    if (followersRes.success && followersRes.data != null) {
      followersCount(followersRes.data!.length);
    }
    if (followingRes.success && followingRes.data != null) {
      followingCount(followingRes.data!.length);
    }

    } catch (_) {
      // Any unexpected error still clears the loading state so the UI unlocks.
    } finally {
      isContentLoading(false);
    }
  }

  String? get userId => _userId;

  /// Open a post in the full-page detail view.
  Future<void> openPostDetail(PostModel post) async {
    Get.toNamed(AppRoutes.POST_DETAIL, arguments: post);
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

  void shareProfile() {
    final handle = username.value.isNotEmpty ? username.value : _userId ?? '';
    final profileUrl = 'https://social-media-uav6.onrender.com/profile/$handle';
    Clipboard.setData(ClipboardData(text: profileUrl));
    Get.snackbar(
      'Link copied!',
      profileUrl,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 3),
      backgroundColor: Colors.black87,
      colorText: Colors.white,
      margin: const EdgeInsets.all(12),
    );
  }

  Future<void> logout() async {
    await _authRepo.logout();
    AuthSession.setLoggedIn(false);
    Get.find<SocketService>().disconnect();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
