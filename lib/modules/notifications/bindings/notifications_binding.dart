import 'package:get/get.dart';

import '../../../data/repositories/notification_repository.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    // Re-use the instance already created by MainBinding if present,
    // otherwise create it (e.g. deep-link entry).
    if (!Get.isRegistered<NotificationsController>()) {
      Get.lazyPut<NotificationsController>(
        () => NotificationsController(Get.find<NotificationRepository>()),
      );
    }
  }
}
