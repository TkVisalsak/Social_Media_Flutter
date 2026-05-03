import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../data/network/dio_client.dart';
import '../../../data/providers/auth_provider.dart';
import '../../../data/repositories/auth_repository.dart';
import '../controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<Dio>(() => DioClient.createDio());
    Get.lazyPut<AuthProvider>(() => AuthProvider(Get.find<Dio>()));
    Get.lazyPut<AuthRepository>(() => AuthRepositoryImpl(Get.find<AuthProvider>()));
    Get.lazyPut<AuthController>(() => AuthController(Get.find<AuthRepository>()));
  }
}