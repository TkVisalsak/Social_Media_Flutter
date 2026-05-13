import 'package:flutter/material.dart';

class ChatSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode             focusNode;
  final bool                  isActive;
  final VoidCallback          onTap;
  final VoidCallback          onCancel;

  const ChatSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.isActive,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 44,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFEFF1F4),
                borderRadius: BorderRadius.circular(22),
              ),
              child: Row(
                children: [
                  Icon(Icons.search, color: isActive ? const Color(0xFF0095F6) : const Color(0xFF8E939A), size: 22),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      focusNode: focusNode,
                      onTap: onTap,
                      style: const TextStyle(color: Colors.black, fontSize: 15),
                      decoration: const InputDecoration(
                        isCollapsed: true,
                        border: InputBorder.none,
                        hintText: 'Messages or people...',
                        hintStyle: TextStyle(color: Color(0xFF8E939A), fontSize: 15),
                      ),
                    ),
                  ),
                  if (isActive && controller.text.isNotEmpty)
                    GestureDetector(
                      onTap: controller.clear,
                      child: const Icon(Icons.cancel, color: Color(0xFF8E939A), size: 18),
                    ),
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: isActive
                ? Padding(
                    padding: const EdgeInsets.only(left: 12),
                    child: GestureDetector(
                      onTap: onCancel,
                      child: const Text('Cancel',
                          style: TextStyle(color: Color(0xFF0095F6), fontSize: 15, fontWeight: FontWeight.w600)),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}
