import 'package:get/get.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/auth_repository.dart';

class SettingsController extends GetxController {
  SettingsController(this._repo);
  final AuthRepository _repo;

  final followersListPublic = true.obs;
  final followingListPublic = true.obs;
  final savedPostsPublic    = false.obs;
  final isSaving            = false.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    final user = await LocalStorage.user;
    if (user != null) {
      followersListPublic(user.followersListPublic);
      followingListPublic(user.followingListPublic);
      savedPostsPublic(user.savedPostsPublic);
    }
  }

  Future<void> updateFollowersListPublic(bool v) async {
    followersListPublic(v);
    await _save();
  }

  Future<void> updateFollowingListPublic(bool v) async {
    followingListPublic(v);
    await _save();
  }

  Future<void> updateSavedPostsPublic(bool v) async {
    savedPostsPublic(v);
    await _save();
  }

  Future<void> _save() async {
    isSaving(true);
    await _repo.updatePrivacy(
      followersListPublic: followersListPublic.value,
      followingListPublic: followingListPublic.value,
      savedPostsPublic: savedPostsPublic.value,
    );
    isSaving(false);
  }
}
