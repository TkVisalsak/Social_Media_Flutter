import 'dart:async';
import 'dart:math';

import 'package:get/get.dart';

import '../../../data/models/post_model.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/user_repository.dart';

class UserSearchController extends GetxController {
  final UserRepository _repo;
  final FeedRepository _feedRepo;
  UserSearchController(this._repo, this._feedRepo);

  // ── User search ───────────────────────────────
  final results   = <UserModel>[].obs;
  final isLoading = false.obs;
  final error     = RxnString();
  final query     = ''.obs;

  // ── Explore grid ──────────────────────────────
  final explorePosts   = <PostModel>[].obs;
  final isExploreLoading = false.obs;

  Timer? _debounce;
  String _lastQuery = '';

  @override
  void onInit() {
    super.onInit();
    _fetchExplore();
  }

  Future<void> _fetchExplore() async {
    isExploreLoading(true);
    final res = await _feedRepo.getFeed(1);
    if (res.success && res.data != null) {
      final withImages = res.data!
          .where((p) => p.firstImageUrl != null && p.firstImageUrl!.isNotEmpty)
          .toList();
      withImages.shuffle(Random());
      explorePosts.assignAll(withImages);
    }
    isExploreLoading(false);
  }

  Future<void> refreshExplore() => _fetchExplore();

  void onQueryChanged(String q) {
    _debounce?.cancel();
    final trimmed = q.trim();
    query(trimmed);

    if (trimmed.isEmpty) {
      results.clear();
      error(null);
      isLoading(false);
      _lastQuery = '';
      return;
    }

    if (trimmed == _lastQuery) return;

    _debounce = Timer(const Duration(milliseconds: 350), () => _search(trimmed));
  }

  Future<void> _search(String q) async {
    _lastQuery = q;
    isLoading(true);
    error(null);

    final res = await _repo.search(q);

    if (res.success) {
      results.assignAll(res.data!);
    } else {
      error(res.error);
      results.clear();
    }

    isLoading(false);
  }

  @override
  void onClose() {
    _debounce?.cancel();
    super.onClose();
  }
}
