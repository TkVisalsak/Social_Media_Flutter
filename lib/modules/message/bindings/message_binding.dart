import 'package:get/get.dart';

import '../controllers/message_controller.dart';

class DirectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DirectController>(() => DirectController());
  }
}

