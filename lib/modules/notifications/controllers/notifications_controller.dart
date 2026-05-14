import 'package:get/get.dart';

import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';

class NotificationsController extends GetxController {
  NotificationsController(this._repo);
  final NotificationRepository _repo;

  final notifications = <NotificationModel>[].obs;
  final isLoading     = false.obs;
  final error         = RxnString();

  int get unreadCount => notifications.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    isLoading(true);
    error(null);
    final res = await _repo.getAll();
    if (res.success && res.data != null) {
      notifications.assignAll(res.data!);
    } else {
      error(res.error);
    }
    isLoading(false);
  }

  Future<void> markRead(String id) async {
    final idx = notifications.indexWhere((n) => n.id == id);
    if (idx < 0 || notifications[idx].isRead) return;
    notifications[idx] = notifications[idx].copyWith(isRead: true);
    await _repo.markRead(id);
  }

  Future<void> markAllRead() async {
    for (var i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        notifications[i] = notifications[i].copyWith(isRead: true);
      }
    }
    await _repo.markAllRead();
  }
}
