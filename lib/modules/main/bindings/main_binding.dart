import 'package:get/get.dart';

import '../../../core/services/socket_service.dart';
import '../../feed/bindings/feed_binding.dart';
import '../../message/bindings/message_binding.dart';
import '../../profile/bindings/profile_binding.dart';
import '../../search/bindings/search_binding.dart';
import '../../shorts/bindings/shorts_binding.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    FeedBinding().dependencies();
    ShortsBinding().dependencies();
    DirectBinding().dependencies();
    ProfileBinding().dependencies();
    SearchBinding().dependencies();

    // Connect socket for users who were already logged in when the app started.
    Get.find<SocketService>().connect();
  }
}
