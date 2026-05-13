import 'package:get/get.dart';

import '../../../data/models/short_model.dart';
import '../../../data/repositories/short_repository.dart';

class ShortsController extends GetxController {
  ShortsController(this._repo);
  final ShortRepository _repo;

  final shorts    = <ShortModel>[].obs;
  final isLoading = false.obs;
  final error     = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchShorts();
  }

  Future<void> fetchShorts() async {
    isLoading.value = true;
    error.value     = null;
    final res = await _repo.getAllShorts();
    if (res.success && res.data != null) {
      shorts.assignAll(res.data!);
    } else {
      error.value = res.error;
    }
    isLoading.value = false;
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
}
