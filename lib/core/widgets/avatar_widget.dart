import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Reusable avatar widget that safely loads network images with fallbacks.
class AvatarWidget extends StatelessWidget {
  final String? photoUrl;
  final String name;
  final double radius;
  final double borderWidth;
  final Color borderColor;

  const AvatarWidget({
    super.key,
    this.photoUrl,
    required this.name,
    this.radius = 24,
    this.borderWidth = 0,
    this.borderColor = Colors.white,
  });

  String get _initials {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0][0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final diameter = radius * 2;

    Widget imageContent;
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      imageContent = Image.network(
        photoUrl!,
        width: diameter,
        height: diameter,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildInitials(),
      );
    } else {
      imageContent = _buildInitials();
    }

    return Container(
      width: diameter,
      height: diameter,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: borderWidth > 0
            ? Border.all(color: borderColor, width: borderWidth)
            : null,
        boxShadow: borderWidth > 0
            ? [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: ClipOval(child: imageContent),
    );
  }

  Widget _buildInitials() {
    return Container(
      color: AppColors.primaryLight,
      alignment: Alignment.center,
      child: Text(
        _initials,
        style: TextStyle(
          fontSize: radius * 0.75,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
