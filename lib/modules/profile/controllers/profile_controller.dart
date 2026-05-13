import 'package:get/get.dart';

import '../../../data/providers/local_storage.dart';

class ProfileController extends GetxController {
  final isLoading      = false.obs;
  final username       = ''.obs;
  final name           = ''.obs;
  final bio            = ''.obs;
  final website        = ''.obs;
  final profilePic     = ''.obs;
  final postsCount     = 0.obs;
  final followersCount = 0.obs;
  final followingCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    isLoading(true);
    final user = await LocalStorage.user;
    if (user != null) {
      username(user.username ?? user.email.split('@').first);
      name(user.fullName ?? user.username ?? '');
      bio(user.bio ?? '');
      profilePic(user.profilePic ?? '');
    }
    isLoading(false);
  }

  void updateProfile() => Get.back();
}
