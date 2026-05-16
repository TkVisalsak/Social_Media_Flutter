import 'package:get/get.dart';
import '../../../data/models/highlight_model.dart';
import '../../../data/repositories/highlight_repository.dart';

class HighlightsController extends GetxController {
  HighlightsController(this._repo);
  final HighlightRepository _repo;

  final highlights = <HighlightModel>[].obs;
  final isLoading  = false.obs;

  @override
  void onInit() { super.onInit(); fetch(); }

  Future<void> fetch() async {
    isLoading(true);
    final res = await _repo.getMyHighlights();
    if (res.success && res.data != null) highlights.assignAll(res.data!);
    isLoading(false);
  }

  Future<void> createHighlight(String title, {String? coverImagePath}) async {
    final res = await _repo.create(title, [], coverImagePath: coverImagePath);
    if (res.success && res.data != null) highlights.insert(0, res.data!);
  }

  Future<void> deleteHighlight(String id) async {
    final res = await _repo.delete(id);
    if (res.success) highlights.removeWhere((h) => h.id == id);
  }
}
