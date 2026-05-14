import 'package:get/get.dart';

import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/save_repository.dart';
import '../../../data/repositories/short_repository.dart';
import '../controllers/profile_controller.dart';

class ProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProfileController>(
      () => ProfileController(
        Get.find<AuthRepository>(),
        Get.find<FeedRepository>(),
        Get.find<ShortRepository>(),
        Get.find<SaveRepository>(),
      ),
    );
  }
}

