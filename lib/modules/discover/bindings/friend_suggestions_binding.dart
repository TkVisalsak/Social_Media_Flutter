import 'package:get/get.dart';

import '../../../data/repositories/follow_repository.dart';
import '../../../data/repositories/hobby_repository.dart';
import '../controllers/friend_suggestions_controller.dart';

class FriendSuggestionsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FriendSuggestionsController>(
      () => FriendSuggestionsController(
        Get.find<HobbyRepository>(),
        Get.find<FollowRepository>(),
      ),
    );
  }
}
