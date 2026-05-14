import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/repost_model.dart';
import '../../../data/models/short_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/repositories/repost_repository.dart';
import '../../../data/repositories/short_repository.dart';

class OtherProfileController extends GetxController {
  final FollowRepository   _followRepo;
  final FeedRepository     _feedRepo;
  final ShortRepository    _shortRepo;
  final RepostRepository   _repostRepo;
  final MessageRepository  _messageRepo;

  OtherProfileController(
    this._followRepo,
    this._feedRepo,
    this._shortRepo,
    this._repostRepo,
    this._messageRepo,
  );

  // ── Profile ──────────────────────────────────────
  late UserModel user;

  final isLoading      = true.obs;
  final isFollowing    = false.obs;
  final followersCount = 0.obs;
  final followingCount = 0.obs;
  final postsCount     = 0.obs;

  // ── Content tabs ─────────────────────────────────
  final posts   = <PostModel>[].obs;
  final shorts  = <ShortModel>[].obs;
  final reposts = <RepostModel>[].obs;

  final isFollowLoading  = false.obs;
  final isDmLoading      = false.obs;

  @override
  void onInit() {
    super.onInit();
    user = Get.arguments as UserModel;
    _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading(true);
    final id = user.id;

    final results = await Future.wait([
      _followRepo.isFollowing(id),
      _followRepo.getFollowers(id),
      _followRepo.getFollowing(id),
      _feedRepo.getUserPosts(id),
      _shortRepo.getByUser(id),
      _repostRepo.getUserReposts(id),
    ]);

    if (results[0].success) isFollowing(results[0].data as bool);
    if (results[1].success) followersCount((results[1].data as List).length);
    if (results[2].success) followingCount((results[2].data as List).length);
    if (results[3].success) {
      final p = results[3].data as List<PostModel>;
      posts.assignAll(p);
      postsCount(p.length);
    }
    if (results[4].success) shorts.assignAll(results[4].data as List<ShortModel>);
    if (results[5].success) reposts.assignAll(results[5].data as List<RepostModel>);

    isLoading(false);
  }

  Future<void> openDM() async {
    if (isDmLoading.value) return;
    isDmLoading(true);

    final res = await _messageRepo.getOrCreateDm(user.id);

    isDmLoading(false);

    if (res.success && res.data != null) {
      Get.toNamed(AppRoutes.CHAT, arguments: res.data);
    } else {
      Get.snackbar(
        'Message',
        res.error ?? 'Cannot open conversation',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 3),
      );
    }
  }

  void openPostDetail(PostModel post) {
    Get.toNamed(AppRoutes.POST_DETAIL, arguments: post);
  }

  Future<void> toggleFollow() async {
    if (isFollowLoading.value) return;
    isFollowLoading(true);

    final wasFollowing = isFollowing.value;
    // Optimistic update
    isFollowing(!wasFollowing);
    followersCount(followersCount.value + (wasFollowing ? -1 : 1));

    final res = wasFollowing
        ? await _followRepo.unfollow(user.id)
        : await _followRepo.follow(user.id);

    if (!res.success) {
      // Revert on failure
      isFollowing(wasFollowing);
      followersCount(followersCount.value + (wasFollowing ? 1 : -1));
    }

    isFollowLoading(false);
  }
}
