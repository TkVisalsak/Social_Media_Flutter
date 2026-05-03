import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/providers/feed_provider.dart';
import '../../../data/repositories/feed_repository.dart';
import '../controllers/feed_controller.dart';

class FeedBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<FeedProvider>(
      () => FeedProvider(Get.find<Dio>()),
    );
    Get.lazyPut<FeedRepository>(
      () => FeedRepositoryImpl(Get.find<FeedProvider>()),
    );
    Get.lazyPut<FeedController>(
      () => FeedController(Get.find<FeedRepository>()),
    );
  }
}