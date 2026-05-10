import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_bottom_navbar.dart';
import '../controllers/shorts_controller.dart';
import '../widgets/reel_item.dart';

class ShortsView extends GetView<ShortsController> {
  const ShortsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      bottomNavigationBar: const AppBottomNavBar(
        current: AppNavTab.reels,
        dark: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.shorts.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.white),
          );
        }

        if (controller.shorts.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Text(
                controller.error.value ?? 'No reels yet.',
                style: const TextStyle(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return _ReelsPager(shorts: controller.shorts.toList());
      }),
    );
  }
}

class _ReelsPager extends StatefulWidget {
  final List shorts;
  const _ReelsPager({required this.shorts});

  @override
  State<_ReelsPager> createState() => _ReelsPagerState();
}

class _ReelsPagerState extends State<_ReelsPager> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      scrollDirection: Axis.vertical,
      itemCount: widget.shorts.length,
      onPageChanged: (i) => setState(() => _index = i),
      itemBuilder: (_, i) => ReelItem(
        short: widget.shorts[i],
        active: i == _index,
      ),
    );
  }
}
