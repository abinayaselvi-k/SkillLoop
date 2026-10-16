import 'package:flutter/material.dart';

/// SkillLoop Design System Colors
/// Preserves the visual styling of the wireframe with soft pastels and lavender/purple accents.
class AppColors {
  AppColors._();

  // Primary Accent (Lavender / Indigo)
  static const Color primary = Color(0xFF6366F1);
  static const Color primaryLight = Color(0xFFE9E9FF);
  static const Color primarySoft = Color(0xFFF2EEFF);
  static const Color primaryTint = Color(0xFFF0F1FF);

  // Background & Surfaces
  static const Color background = Color(0xFFF7F8FC);
  static const Color card = Colors.white;
  static const Color inputBackground = Color(0xFFF0F2F7);
  static const Color tagBackground = Color(0xFFF6F7FA);

  // Borders & Dividers
  static const Color border = Color(0xFFE8EAF0);
  static const Color borderLight = Color(0xFFE5E7EB);

  // Typography
  static const Color textPrimary = Color(0xFF20232A);
  static const Color textSecondary = Color(0xFF7B8190);
  static const Color textMuted = Color(0xFF8B93A3);
  static const Color textDark = Color(0xFF252832);
  static const Color textBody = Color(0xFF596070);

  // Status & Badges
  static const Color success = Color(0xFF19B77A);
  static const Color successDark = Color(0xFF19A974);
  static const Color warning = Color(0xFFFFB72B);
  static const Color ratingText = Color(0xFF4A4E59);
  static const Color error = Color(0xFFEF4444);
  static const Color errorSoft = Color(0xFFFEE2E2);

  // Gradients
  static const LinearGradient perfectMatchGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFF0F2FF),
      Color(0xFFEFFFF8),
    ],
  );

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF6366F1),
      Color(0xFF818CF8),
    ],
  );
}
