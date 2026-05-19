import 'package:get/get.dart';

import '../../../data/models/user_model.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/hobby_repository.dart';

class FriendSuggestionsController extends GetxController {
  final HobbyRepository _hobbyRepo;
  final FollowRepository _followRepo;

  FriendSuggestionsController(this._hobbyRepo, this._followRepo);

  final suggestions      = <UserModel>[].obs;
  final notFollowingBack = <UserModel>[].obs;
  final followedIds      = <String>{}.obs; // tracks optimistic follow taps
  final isLoading        = false.obs;

  @override
  void onInit() {
    super.onInit();
    _load();
  }

  Future<void> _load() async {
    isLoading.value = true;
    try {
      // Run both requests in parallel without mixing types in Future.wait.
      final suggestionsF    = _hobbyRepo.getSuggestions();
      final notFollowingF   = _followRepo.getNotFollowingBack();

      final suggestionsRes  = await suggestionsF;
      final notFollowingRes = await notFollowingF;

      if (suggestionsRes.success && suggestionsRes.data != null) {
        suggestions.assignAll(suggestionsRes.data!.map((s) => s.user).toList());
      }
      if (notFollowingRes.success && notFollowingRes.data != null) {
        notFollowingBack.assignAll(notFollowingRes.data!);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> followUser(String userId) async {
    followedIds.add(userId); // optimistic
    final res = await _followRepo.follow(userId);
    if (res.success) {
      notFollowingBack.removeWhere((u) => u.id == userId);
    } else {
      followedIds.remove(userId); // revert on failure
    }
  }

  Future<void> refresh() => _load();
}
