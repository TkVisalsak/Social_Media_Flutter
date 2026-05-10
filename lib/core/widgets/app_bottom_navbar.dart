import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';

enum AppNavTab { home, reels, search, chat, profile }

class AppBottomNavBar extends StatelessWidget {
  final AppNavTab current;
  final bool dark;

  const AppBottomNavBar({
    super.key,
    required this.current,
    this.dark = false,
  });

  void _go(AppNavTab tab) {
    if (tab == current) return;
    switch (tab) {
      case AppNavTab.home:
        Get.offAllNamed(AppRoutes.FEED);
      case AppNavTab.reels:
        Get.offAllNamed(AppRoutes.SHORTS);
      case AppNavTab.search:
        Get.snackbar('Search', 'Search is not wired up yet',
            snackPosition: SnackPosition.BOTTOM);
      case AppNavTab.chat:
        Get.offAllNamed(AppRoutes.DIRECT);
      case AppNavTab.profile:
        Get.offAllNamed(AppRoutes.PROFILE);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bg = dark ? Colors.black : Colors.white;
    final selected = dark ? Colors.white : Colors.black;
    final unselected = dark ? Colors.white70 : Colors.black54;

    return BottomNavigationBar(
      currentIndex: current.index,
      onTap: (i) => _go(AppNavTab.values[i]),
      type: BottomNavigationBarType.fixed,
      elevation: 0,
      backgroundColor: bg,
      selectedItemColor: selected,
      unselectedItemColor: unselected,
      showSelectedLabels: false,
      showUnselectedLabels: false,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_filled),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.video_library_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.send_outlined),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: '',
        ),
      ],
    );
  }
}
