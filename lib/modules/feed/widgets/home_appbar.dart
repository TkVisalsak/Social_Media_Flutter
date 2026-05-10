import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../app/routes/app_routes.dart';
import 'feed_create_flow.dart';

class HomeAppBar extends StatelessWidget {
  const HomeAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(
        top: 18,
        left: 20,
        right: 20,
        bottom: 14,
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Expanded(
              child: Text(
                'Social app',
                style: TextStyle(
                  fontSize: 32,
                  fontFamily: 'Cookie',
                  color: Colors.black87,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            GestureDetector(
              onTap: () => FeedCreateFlow.showOptions(context),
              child: const Icon(
                CupertinoIcons.add,
                size: 26,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 18),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.NOTIFICATIONS),
              child: const Icon(
                CupertinoIcons.heart,
                size: 26,
                color: Colors.black87,
              ),
            ),
            const SizedBox(width: 18),
            GestureDetector(
              onTap: () => Get.toNamed(AppRoutes.DIRECT),
              child: const Icon(
                CupertinoIcons.chat_bubble,
                size: 26,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
