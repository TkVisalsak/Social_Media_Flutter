import 'package:get/get.dart';

import '../controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    // Splash must instantiate immediately so onInit can redirect.
    Get.put<SplashController>(SplashController());
  }
}