import 'package:get/get.dart';

import '../../../core/services/socket_service.dart';
import '../../../data/repositories/highlight_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../feed/bindings/feed_binding.dart';
import '../../message/bindings/message_binding.dart';
import '../../notifications/controllers/notifications_controller.dart';
import '../../profile/bindings/profile_binding.dart';
import '../../profile/controllers/highlights_controller.dart';
import '../../search/bindings/search_binding.dart';
import '../../shorts/bindings/shorts_binding.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    FeedBinding().dependencies();
    ShortsBinding().dependencies();
    DirectBinding().dependencies();
    ProfileBinding().dependencies();
    SearchBinding().dependencies();

    // Notifications controller lives at the main shell level so the bell badge
    // is reactive from any tab without re-fetching on every navigation.
    Get.lazyPut<NotificationsController>(
      () => NotificationsController(Get.find<NotificationRepository>()),
      fenix: true,
    );

    Get.lazyPut<HighlightsController>(
      () => HighlightsController(Get.find<HighlightRepository>()),
      fenix: true,
    );

    // Connect socket for users who were already logged in when the app started.
    Get.find<SocketService>().connect();
  }
}
