import 'package:get/get.dart';

import '../../../data/repositories/comments_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../controllers/post_detail_controller.dart';

class PostDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostDetailController>(
      () => PostDetailController(
        Get.find<CommentsRepository>(),
        Get.find<FeedRepository>(),
      ),
    );
  }
}
