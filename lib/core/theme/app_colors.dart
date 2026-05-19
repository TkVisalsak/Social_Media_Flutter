import 'package:flutter/material.dart';

abstract class AppColors {
  static const Color feedBackground  = Color(0xFFFFFBF7);
  static const Color cardBackground  = Colors.white;
  static const Color divider         = Color(0xFFE5E5E5);
  static const Color avatarFill      = Color(0xFFD8B4A0);
  static const List<Color> storyRing = [
    Color(0xFFFF5F6D),
    Color(0xFFFF9966),
    Color(0xFFFFC371),
  ];
  static const List<Color> storyRingViewed = [
    Colors.grey,
    Colors.grey,
  ];
  static const Color like        = Color(0xFFFF4D6D);
  static const Color accent      = Color(0xFF3797F0);
  static const Color primaryBlue = Color(0xFF0095F6);
  static const Color online      = Color(0xFF22C55E);
  static const Color repost      = Color(0xFFFFD700);
  static const Color save        = Color(0xFFFFD700);
}
