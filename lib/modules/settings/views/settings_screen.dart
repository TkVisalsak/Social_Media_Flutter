import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text('Settings & Privacy',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w700, fontSize: 18)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Obx(() => ListView(
        children: [
          const _SectionHeader('Privacy'),
          _PrivacyTile(
            title: 'Followers list',
            subtitle: 'Allow others to see who follows you',
            value: controller.followersListPublic.value,
            onChanged: (v) => controller.updateFollowersListPublic(v),
          ),
          _PrivacyTile(
            title: 'Following list',
            subtitle: 'Allow others to see who you follow',
            value: controller.followingListPublic.value,
            onChanged: (v) => controller.updateFollowingListPublic(v),
          ),
          _PrivacyTile(
            title: 'Saved posts',
            subtitle: 'Allow others to see your saved posts',
            value: controller.savedPostsPublic.value,
            onChanged: (v) => controller.updateSavedPostsPublic(v),
          ),
          if (controller.isSaving.value)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            ),
        ],
      )),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(title,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: Colors.grey, letterSpacing: 0.5)),
    );
  }
}

class _PrivacyTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _PrivacyTile({required this.title, required this.subtitle, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return SwitchListTile.adaptive(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
      subtitle: Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 13)),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF3797F0),
    );
  }
}
