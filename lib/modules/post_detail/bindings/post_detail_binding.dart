import 'package:dio/dio.dart';
import 'package:get/get.dart';

import '../../../data/providers/comments_provider.dart';
import '../../../data/repositories/comments_repository.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CommentsProvider>(() => CommentsProvider(Get.find<Dio>()));
    Get.lazyPut<CommentsRepository>(
      () => CommentsRepositoryImpl(Get.find<CommentsProvider>()),
    );
    Get.lazyPut<PostDetailController>(
      () => PostDetailController(Get.find<CommentsRepository>()),
    );
  }
}

