import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/widgets/app_bottom_navbar.dart';
import '../controllers/feed_controller.dart';
import '../widgets/home_appbar.dart';
import '../widgets/post_card.dart';
import '../widgets/story_section.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFBF7),
      bottomNavigationBar: const AppBottomNavBar(current: AppNavTab.home),
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => controller.fetchFeed(refresh: true),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >=
                  notification.metrics.maxScrollExtent - 200) {
                controller.fetchFeed();
              }
              return false;
            },
            child: CustomScrollView(
              slivers: [
                const SliverToBoxAdapter(child: HomeAppBar()),
                const SliverToBoxAdapter(child: StorySection()),
                SliverToBoxAdapter(
                  child: Container(
                    margin: const EdgeInsets.only(top: 14),
                    width: double.infinity,
                    height: 1.2,
                    color: const Color(0xFFE5E5E5),
                  ),
                ),
                Obx(() {
                  if (controller.isLoading.value &&
                      controller.posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!controller.isLoading.value &&
                      controller.posts.isEmpty) {
                    return SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            controller.error.value ??
                                'No posts yet — pull to refresh.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        if (i == controller.posts.length) {
                          if (!controller.hasMore.value) {
                            return const SizedBox(height: 24);
                          }
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child:
                                Center(child: CircularProgressIndicator()),
                          );
                        }
                        return PostCard(post: controller.posts[i]);
                      },
                      childCount: controller.posts.length + 1,
                    ),
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
