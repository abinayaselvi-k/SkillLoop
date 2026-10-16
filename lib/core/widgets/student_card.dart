import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import 'avatar_widget.dart';

/// StudentCard widget preserving the exact wireframe look and dimensions.
class StudentCard extends StatelessWidget {
  final String name;
  final String course;
  final String skill;
  final List<String> tags;
  final String rating;
  final String avatar;
  final bool isAvailable;
  final VoidCallback onPressed;

  const StudentCard({
    super.key,
    required this.name,
    required this.course,
    required this.skill,
    required this.tags,
    required this.rating,
    required this.avatar,
    this.isAvailable = true,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 180,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 9),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // STATUS + RATING
          Row(
            children: [
              Icon(
                Icons.circle,
                size: 6,
                color: isAvailable ? AppColors.success : AppColors.textMuted,
              ),
              const SizedBox(width: 4),
              Text(
                isAvailable ? 'Available' : 'Busy',
                style: TextStyle(
                  fontSize: 9,
                  color: isAvailable ? AppColors.successDark : AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.star_rounded,
                size: 12,
                color: AppColors.warning,
              ),
              const SizedBox(width: 2),
              Text(
                rating,
                style: const TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ratingText,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // AVATAR
          AvatarWidget(
            photoUrl: avatar,
            name: name,
            radius: 24,
          ),

          const SizedBox(height: 6),

          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF292D36),
            ),
          ),

          const SizedBox(height: 2),

          Text(
            course,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 9,
              color: Color(0xFF8A909D),
            ),
          ),

          const SizedBox(height: 8),

          // SKILL
          Container(
            width: double.infinity,
            height: 18,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.primaryTint,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Text(
              skill.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),

          const SizedBox(height: 5),

          // TAGS
          SizedBox(
            height: 18,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: tags.take(2).map((tag) {
                return Flexible(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 2),
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.tagBackground,
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      tag,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 8,
                        color: Color(0xFF737987),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const Spacer(),

          // BUTTON
          GestureDetector(
            onTap: onPressed,
            child: Container(
              width: double.infinity,
              height: 27,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'View Profile',
                style: TextStyle(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
