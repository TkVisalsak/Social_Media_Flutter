import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class StoryAvatar extends StatelessWidget {
  final String?  imagePath;
  final bool     isNetworkImage;
  final String   username;
  final double   radius;
  final bool     hasRing;
  final bool     isViewed;
  final bool     showAddBadge;

  const StoryAvatar({
    super.key,
    this.imagePath,
    this.isNetworkImage = false,
    required this.username,
    this.radius       = 30,
    this.hasRing      = false,
    this.isViewed     = false,
    this.showAddBadge = false,
  });

  ImageProvider? _image() {
    if (imagePath == null) return null;
    if (isNetworkImage || imagePath!.startsWith('http')) {
      return NetworkImage(imagePath!);
    }
    return AssetImage(imagePath!);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            shape:    BoxShape.circle,
            gradient: hasRing
                ? LinearGradient(
                    colors: isViewed
                        ? AppColors.storyRingViewed
                        : AppColors.storyRing,
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
              radius:          radius,
              backgroundColor: AppColors.avatarFill,
              backgroundImage: _image(),
              child: _image() == null
                  ? Text(
                      username[0].toUpperCase(),
                      style: TextStyle(
                        color:      Colors.white,
                        fontSize:   radius,
                        fontWeight: FontWeight.w300,
                        fontStyle:  FontStyle.italic,
                      ),
                    )
                  : null,
            ),
          ),
        ),
        if (showAddBadge)
          Positioned(
            bottom: 2,
            right:  2,
            child: Container(
              width:  24,
              height: 24,
              decoration: BoxDecoration(
                color:  Colors.black,
                shape:  BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 4)],
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 14),
            ),
          ),
      ],
    );
  }
}
