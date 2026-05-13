import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/profile_controller.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close, size: 28),
          onPressed: () => Get.back(),
        ),
        title: const Text('Edit Profile', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.check, color: Color(0xFF0095F6), size: 28),
            onPressed: controller.updateProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            const SizedBox(height: 20),
            Center(
              child: Column(
                children: [
                  Obx(() => CircleAvatar(
                    radius: 45,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: controller.profilePic.value.isNotEmpty
                        ? NetworkImage(controller.profilePic.value) as ImageProvider : null,
                    child: controller.profilePic.value.isEmpty
                        ? Text(controller.username.value.isNotEmpty ? controller.username.value[0].toUpperCase() : '?',
                            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold))
                        : null,
                  )),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Edit picture',
                        style: TextStyle(color: Color(0xFF0095F6), fontWeight: FontWeight.bold, fontSize: 14)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            _buildEditField('Name',    controller.name),
            _buildEditField('Bio',     controller.bio),
            _buildEditField('Website', controller.website),
            const Divider(),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {},
                child: const Text('Switch to Professional Account',
                    style: TextStyle(color: Color(0xFF0095F6))),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditField(String label, RxString value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13)),
          TextField(
            controller: TextEditingController(text: value.value),
            onChanged: (val) => value.value = val,
            style: const TextStyle(fontSize: 16),
            decoration: const InputDecoration(
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
              border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
            ),
          ),
        ],
      ),
    );
  }
}
