import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../data/network/dio_client.dart';
import '../../data/providers/auth_provider.dart';
import '../../data/repositories/auth_repository.dart';

class InitialBinding implements Bindings {
  @override
  void dependencies() {
    // ── Dio singleton ─────────────────────────
    Get.put<Dio>(DioClient.instance, permanent: true);

    // ── Providers ─────────────────────────────
    Get.lazyPut<AuthProvider>(
      () => AuthProvider(Get.find<Dio>()),
      fenix: true,
    );

    // ── Repositories ──────────────────────────
    Get.lazyPut<AuthRepository>(
      () => AuthRepositoryImpl(Get.find<AuthProvider>()),
      fenix: true,
    );
  }
}