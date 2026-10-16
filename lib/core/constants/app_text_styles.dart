import 'package:flutter/material.dart';
import 'app_colors.dart';

/// SkillLoop Typography Hierarchy
class AppTextStyles {
  AppTextStyles._();

  static const TextStyle heading1 = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textPrimary,
    letterSpacing: -0.5,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
    letterSpacing: -0.3,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const TextStyle subtitle = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textSecondary,
  );

  static const TextStyle body = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w400,
    color: AppColors.textBody,
    height: 1.4,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    color: Color(0xFF292D36),
  );

  static const TextStyle cardSubtitle = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w400,
    color: Color(0xFF8A909D),
  );

  static const TextStyle buttonText = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 9,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
  );

  static const TextStyle tag = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w600,
    color: Color(0xFF737987),
  );

  static const TextStyle skillBadge = TextStyle(
    fontSize: 8,
    fontWeight: FontWeight.w700,
    color: AppColors.primary,
    letterSpacing: 0.2,
  );
}
