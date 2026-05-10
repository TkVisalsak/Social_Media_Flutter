import 'package:get/get.dart';

import '../../../data/models/story_model.dart';
import '../../../data/repositories/story_repository.dart';

/// Loads the home stories bar (one row per user with active stories).
class StoryFeedController extends GetxController {
  StoryFeedController(this._repo);
  final StoryRepository _repo;

  final stories = <StoryModel>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  /// Group stories by user so the bar shows one avatar per user.
  List<List<StoryModel>> get groupedByUser {
    final byUser = <String, List<StoryModel>>{};
    for (final s in stories) {
      byUser.putIfAbsent(s.user.id, () => []).add(s);
    }
    return byUser.values.toList();
  }

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    if (isLoading.value) return;
    isLoading(true);
    error(null);
    final res = await _repo.getFeed();
    if (res.success && res.data != null) {
      stories.assignAll(res.data!);
    } else {
      error(res.error);
    }
    isLoading(false);
  }
}
