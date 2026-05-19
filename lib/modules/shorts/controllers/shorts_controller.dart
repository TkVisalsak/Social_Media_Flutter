import 'package:get/get.dart';

import '../../../data/models/short_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/short_repository.dart';

class ShortsController extends GetxController {
  ShortsController(this._repo, this._followRepo, {this.skipInitialFetch = false});
  final ShortRepository  _repo;
  final FollowRepository _followRepo;
  final bool skipInitialFetch;

  final shorts       = <ShortModel>[].obs;
  final isLoading    = false.obs;
  final error        = RxnString();
  final isTabVisible = false.obs;

  /// 'fyp' or 'friends'
  final selectedFeed = 'fyp'.obs;

  // Follow status cache — avoids redundant API calls for the same user
  final _followCache = <String, bool>{};

  @override
  void onInit() {
    super.onInit();
    if (!skipInitialFetch) fetchShorts();
  }

  Future<void> fetchShorts() async {
    isLoading.value = true;
    error.value     = null;
    final res = selectedFeed.value == 'friends'
        ? await _repo.getFriendsShorts()
        : await _repo.getAllShorts();
    if (res.success && res.data != null) {
      shorts.assignAll(res.data!);
    } else {
      error.value = res.error;
    }
    isLoading.value = false;
  }

  /// Switch between FYP and Friends feeds.
  void switchFeed(String feed) {
    if (selectedFeed.value == feed) return;
    selectedFeed.value = feed;
    fetchShorts();
  }

  Future<bool> createShort({required String filePath, String? caption}) async {
    isLoading(true);
    final me  = await LocalStorage.user;
    final res = await _repo.uploadShort(filePath: filePath, caption: caption);
    isLoading(false);

    if (res.success && res.data != null) {
      final short = res.data!.copyWith(
        user: me ?? const UserModel(id: '', email: ''),
      );
      shorts.insert(0, short);
      Get.snackbar('Reel shared!', 'Your reel is now live.',
          snackPosition: SnackPosition.BOTTOM,
          duration: const Duration(seconds: 3));
      return true;
    }

    Get.snackbar('Upload failed', res.error ?? 'Try again',
        snackPosition: SnackPosition.BOTTOM);
    return false;
  }

  void incrementCommentCount(String shortId) {
    final i = shorts.indexWhere((s) => s.id == shortId);
    if (i < 0) return;
    shorts[i] = shorts[i].copyWith(commentCount: shorts[i].commentCount + 1);
  }

  /// Optimistically increments the share count and persists to the API.
  Future<void> incrementShareCount(String shortId) async {
    final idx = shorts.indexWhere((s) => s.id == shortId);
    if (idx < 0) return;
    shorts[idx] = shorts[idx].copyWith(shareCount: shorts[idx].shareCount + 1);
    await _repo.incrementShare(shortId);
  }

  /// Optimistically toggles the like on the given short and persists to the API.
  Future<void> toggleLike(String shortId) async {
    final idx = shorts.indexWhere((s) => s.id == shortId);
    if (idx < 0) return;

    final s        = shorts[idx];
    final newLiked = !s.isLiked;

    // Update in-place — triggers Obx rebuilds in ReelItem.
    shorts[idx] = s.copyWith(
      isLiked:   newLiked,
      likeCount: s.likeCount + (newLiked ? 1 : -1),
    );

    await _repo.toggleLike(shortId);
  }

  /// Returns follow status for userId, using cache if available.
  Future<bool> getFollowStatus(String userId) async {
    if (_followCache.containsKey(userId)) return _followCache[userId]!;
    final res = await _followRepo.isFollowing(userId);
    final value = res.success ? (res.data ?? false) : false;
    _followCache[userId] = value;
    return value;
  }

  /// Follow user and update cache.
  Future<bool> followUser(String userId) async {
    final res = await _followRepo.follow(userId);
    if (res.success) _followCache[userId] = true;
    return res.success;
  }

  /// Unfollow user and update cache.
  Future<bool> unfollowUser(String userId) async {
    final res = await _followRepo.unfollow(userId);
    if (res.success) _followCache[userId] = false;
    return res.success;
  }

  /// Optimistically removes the short from the list and deletes it via API.
  Future<void> deleteShort(String id) async {
    shorts.removeWhere((s) => s.id == id);
    await _repo.deleteShort(id);
  }
}
