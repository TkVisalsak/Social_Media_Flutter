import 'package:get/get.dart';

import '../../../data/repositories/user_repository.dart';
import '../controllers/search_controller.dart';

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserSearchController>(
      () => UserSearchController(Get.find<UserRepository>()),
    );
  }
}
