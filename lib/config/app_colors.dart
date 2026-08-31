import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF22C55E);
  static const Color primaryLight = Color(0xFFDCFCE7);
  static const Color primaryDark = Color(0xFF15803D);

  static const Color background = Color(0xFFF8FAFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F5F9);

  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textMuted = Color(0xFF94A3B8);

  static const Color folderBlue = Color(0xFF38BDF8);
  static const Color folderBlueLight = Color(0xFFE0F2FE);

  static const Color folderGreen = Color(0xFF4ADE80);
  static const Color folderGreenLight = Color(0xFFDCFCE7);

  static const Color folderOrange = Color(0xFFFB923C);
  static const Color folderOrangeLight = Color(0xFFFFEDD5);

  static const Color folderPurple = Color(0xFFA855F7);
  static const Color folderPurpleLight = Color(0xFFF3E8FF);

  static const Color folderPink = Color(0xFFF472B6);
  static const Color folderPinkLight = Color(0xFFFCE7F3);

  static const Color folderYellow = Color(0xFFFBBF24);
  static const Color folderYellowLight = Color(0xFFFEF3C7);

  static const Color inProgress = Color(0xFFFB923C);
  static const Color inProgressBg = Color(0xFFFFEDD5);
  static const Color completed = Color(0xFF22C55E);
  static const Color completedBg = Color(0xFFDCFCE7);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerLight = Color(0xFFFEE2E2);

  static const Color border = Color(0xFFE2E8F0);
  static const Color divider = Color(0xFFF1F5F9);

  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get floatingShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.08),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
  ];
}
