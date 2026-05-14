import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

class PostShareSheet extends StatelessWidget {
  final String postId;
  final VoidCallback? onShared;
  const PostShareSheet({super.key, required this.postId, this.onShared});

  String get _deepLink => 'socialmedia://posts/$postId';

  void _copyLink(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _deepLink));
    onShared?.call();
    Navigator.pop(context);
    Get.snackbar(
      'Link copied',
      'Post link copied to clipboard',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 2),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              width: 40, height: 4,
              decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2)),
            ),
            const Text('Share',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ShareOption(
                  icon: Icons.link_rounded,
                  label: 'Copy link',
                  color: Colors.grey[800]!,
                  onTap: () => _copyLink(context),
                ),
                _ShareOption(
                  icon: Icons.chat_rounded,
                  label: 'Message',
                  color: const Color(0xFF3797F0),
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.bookmark_rounded,
                  label: 'Save',
                  color: Colors.black,
                  onTap: () => Navigator.pop(context),
                ),
                _ShareOption(
                  icon: Icons.more_horiz,
                  label: 'More',
                  color: Colors.grey[600]!,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _ShareOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ShareOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 52, height: 52,
            decoration: BoxDecoration(
                color: Colors.grey[100], shape: BoxShape.circle),
            child: Icon(icon, color: color, size: 24),
          ),
          const SizedBox(height: 8),
          Text(label,
              style:
                  const TextStyle(fontSize: 12, color: Colors.black87)),
        ],
      ),
    );
  }
}
