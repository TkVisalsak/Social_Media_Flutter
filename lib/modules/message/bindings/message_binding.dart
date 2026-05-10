import 'package:get/get.dart';

import '../../../data/repositories/message_repository.dart';
import '../controllers/message_controller.dart';

class DirectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectController>(
      () => DirectController(Get.find<MessageRepository>()),
    );
  }
}
