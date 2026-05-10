import 'package:get/get.dart';

import '../../../data/repositories/short_repository.dart';
import '../controllers/shorts_controller.dart';

class ShortsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ShortsController>(
      () => ShortsController(Get.find<ShortRepository>()),
    );
  }
}
