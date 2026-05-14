import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../shared/widgets/animated_nav_bar.dart';
import '../../feed/views/feed_view.dart';
import '../../message/views/message_view.dart';
import '../../profile/views/profile_view.dart';
import '../../search/views/search_view.dart';
import '../../shorts/controllers/shorts_controller.dart';
import '../../shorts/views/shorts_view.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int currentIndex = 0;

  static const List<Widget> _pages = [
    FeedView(),
    ShortsView(),
    SearchView(),
    DirectView(),
    ProfileView(),
  ];

  static const List<NavItem> _navItems = [
    NavItem(icon: Icons.home_rounded,         label: 'Home'),
    NavItem(icon: Icons.movie_rounded,         label: 'Reels'),
    NavItem(icon: Icons.search_rounded,        label: 'Search'),
    NavItem(icon: Icons.chat_bubble_rounded,   label: 'Chats'),
    NavItem(icon: Icons.person_rounded,        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final isReelsPage = currentIndex == 1;

    return Scaffold(
      extendBody: true,
      backgroundColor: isReelsPage ? Colors.black : Colors.white,
      body: IndexedStack(index: currentIndex, children: _pages),
      bottomNavigationBar: AnimatedNavBar(
        items: _navItems,
        selectedIndex: currentIndex,
        onChanged: (index) {
          setState(() { currentIndex = index; });
          Get.find<ShortsController>().isTabVisible.value = (index == 1);
        },
      ),
    );
  }
}
