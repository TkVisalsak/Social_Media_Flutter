import 'package:flutter/material.dart';

class StoryItem extends StatelessWidget {
  final String username;
  final String? imageUrl;
  final bool hasStory;
  final bool isCurrentUser;
  final VoidCallback? onTap;

  const StoryItem({
    super.key,
    required this.username,
    this.imageUrl,
    this.hasStory = false,
    this.isCurrentUser = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final firstLetter =
        username.isNotEmpty ? username[0].toUpperCase() : '?';
    final hasImage = imageUrl != null && imageUrl!.trim().isNotEmpty;

    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.only(right: 12),
        child: Column(
          children: [
            Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: hasStory
                        ? const LinearGradient(
                            colors: [
                              Color(0xFFFF5F6D),
                              Color(0xFFFF9966),
                              Color(0xFFFFC371),
                            ],
                          )
                        : null,
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: CircleAvatar(
                      radius: 30,
                      backgroundColor: const Color(0xFFD8B4A0),
                      backgroundImage:
                          hasImage ? NetworkImage(imageUrl!) : null,
                      child: hasImage
                          ? null
                          : Text(
                              firstLetter,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 30,
                                fontWeight: FontWeight.w300,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                    ),
                  ),
                ),
                if (isCurrentUser && !hasStory)
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.add,
                        color: Colors.white,
                        size: 14,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: 72,
              child: Text(
                isCurrentUser ? 'Your story' : username,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
