import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/theme/app_colors.dart';
import '../controllers/feed_controller.dart';
import '../widgets/home_appbar.dart';
import '../widgets/post_card.dart';
import '../widgets/story_section.dart';

class FeedView extends GetView<FeedController> {
  const FeedView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.feedBackground,
      body: SafeArea(
        bottom: false,
        child: RefreshIndicator(
          onRefresh: () => controller.fetchFeed(refresh: true),
          child: NotificationListener<ScrollNotification>(
            onNotification: (notification) {
              if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 200) {
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
                    height: 1.2,
                    color: AppColors.divider,
                  ),
                ),
                Obx(() {
                  if (controller.isLoading.value && controller.posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }
                  if (!controller.isLoading.value && controller.posts.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 64, color: Colors.grey),
                            const SizedBox(height: 16),
                            Text(
                              controller.error.value ?? 'No posts yet',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        if (index == controller.posts.length) {
                          return controller.hasMore.value
                              ? const Padding(
                                  padding: EdgeInsets.all(16),
                                  child: Center(child: CircularProgressIndicator()),
                                )
                              : const SizedBox(height: 80);
                        }
                        return PostCard(post: controller.posts[index]);
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
