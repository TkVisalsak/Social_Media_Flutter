import 'package:get/get.dart';

import '../../../core/services/socket_service.dart';
import '../../../data/repositories/message_repository.dart';
import '../../../data/repositories/story_repository.dart';
import '../../feed/controllers/story_feed_controller.dart';
import '../controllers/message_controller.dart';

class DirectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectController>(
      () => DirectController(
        Get.find<MessageRepository>(),
        Get.find<SocketService>(),
      ),
    );
    // fenix: true → reuses the instance already alive from the feed tab
    Get.lazyPut<StoryFeedController>(
      () => StoryFeedController(Get.find<StoryRepository>()),
      fenix: true,
    );
  }
}
