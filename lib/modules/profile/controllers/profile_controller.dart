import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import '../../../core/middlewares/auth_middleware.dart';
import '../../../core/services/socket_service.dart';
import '../../../data/models/post_model.dart';
import '../../../data/models/short_model.dart';
import '../../../data/providers/local_storage.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../data/repositories/feed_repository.dart';
import '../../../data/repositories/short_repository.dart';

class ProfileController extends GetxController {
  final AuthRepository  _authRepo;
  final FeedRepository  _feedRepo;
  final ShortRepository _shortRepo;

  ProfileController(this._authRepo, this._feedRepo, this._shortRepo);

  final isLoading      = false.obs;
  final username       = ''.obs;
  final name           = ''.obs;
  final bio            = ''.obs;
  final website        = ''.obs;
  final profilePic     = ''.obs;
  final postsCount     = 0.obs;
  final followersCount = 0.obs;
  final followingCount = 0.obs;

  final myPosts          = <PostModel>[].obs;
  final myShorts         = <ShortModel>[].obs;
  final isContentLoading = false.obs;

  String? _userId;

  @override
  void onInit() {
    super.onInit();
    _loadFromStorage();
  }

  Future<void> _loadFromStorage() async {
    isLoading(true);
    final user = await LocalStorage.user;
    if (user != null) {
      _userId = user.id;
      username(user.username ?? user.email.split('@').first);
      name(user.fullName ?? user.username ?? '');
      bio(user.bio ?? '');
      profilePic(user.profilePic ?? '');
    }
    isLoading(false);
    if (_userId != null) _loadContent();
  }

  Future<void> _loadContent() async {
    isContentLoading(true);
    final postsRes  = await _feedRepo.getUserPosts(_userId!);
    final shortsRes = await _shortRepo.getByUser(_userId!);
    if (postsRes.success && postsRes.data != null) {
      myPosts.assignAll(postsRes.data!);
      postsCount(postsRes.data!.length);
    }
    if (shortsRes.success && shortsRes.data != null) {
      myShorts.assignAll(shortsRes.data!);
    }
    isContentLoading(false);
  }

  void updateProfile() => Get.back();

  Future<void> logout() async {
    await _authRepo.logout();
    AuthSession.setLoggedIn(false);
    Get.find<SocketService>().disconnect();
    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
