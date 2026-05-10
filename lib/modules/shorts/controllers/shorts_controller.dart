import 'package:get/get.dart';

import '../../../data/models/short_model.dart';
import '../../../data/repositories/short_repository.dart';

class ShortsController extends GetxController {
  ShortsController(this._repo);
  final ShortRepository _repo;

  final shorts = <ShortModel>[].obs;
  final isLoading = false.obs;
  final error = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchShorts();
  }

  Future<void> fetchShorts() async {
    isLoading.value = true;
    error.value = null;
    final res = await _repo.getAllShorts();
    if (res.success && res.data != null) {
      shorts.assignAll(res.data!);
    } else {
      error.value = res.error;
    }
    isLoading.value = false;
  }
}
