import 'package:get/get.dart';

import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/repositories/repost_repository.dart';
import '../../../data/repositories/short_repository.dart';
import '../controllers/other_profile_controller.dart';

class OtherProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<OtherProfileController>(
      () => OtherProfileController(
        Get.find<FollowRepository>(),
        Get.find<FeedRepository>(),
        Get.find<ShortRepository>(),
        Get.find<RepostRepository>(),
        Get.find<MessageRepository>(),
      ),
    );
  }
}
