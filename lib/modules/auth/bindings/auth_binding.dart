import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/network/dio_client.dart';
import '../controllers/auth_controller.dart';
import '../../../data/providers/auth_provider.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Dio>(() => DioClient.createDio());
    Get.lazyPut<AuthProvider>(() => AuthProvider(Get.find<Dio>()));
    Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthProvider>()));
  }
}