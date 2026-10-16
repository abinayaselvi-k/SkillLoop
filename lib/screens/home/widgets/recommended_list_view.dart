import 'package:flutter/material.dart';
import 'package:skillloop_ui/skillloop_ui.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/student_card.dart';
import '../../../models/user_profile.dart';
import '../../profile/student_profile_screen.dart';

class RecommendedListView extends StatelessWidget {
  final List<UserProfile> students;
  final VoidCallback onSeeAll;

  const RecommendedListView({
    super.key,
    required this.students,
    required this.onSeeAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 0),
        SkillLoopSectionTitle(
          title: 'Recommended for You',
          titleStyle: AppTextStyles.sectionTitle,
          actionLabel: 'See all',
          actionStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
          onAction: onSeeAll,
          trailingPadding: 22,
        ),

        const SizedBox(height: 11),

        // Horizontal Student Cards
        SizedBox(
          height: 216,
          child: students.isEmpty
              ? _buildEmptyPlaceholder()
              : ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.only(right: 22),
                  itemCount: students.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 10),
                  itemBuilder: (context, index) {
                    final student = students[index];
                    return StudentCard(
                      name: student.fullName,
                      course: student.courseInfo,
                      skill: student.primaryTeachingSkill,
                      tags: student.skillsToTeach.isNotEmpty
                          ? student.skillsToTeach
                          : ['Skills'],
                      rating: student.averageRating.toStringAsFixed(1),
                      avatar: student.photoUrl,
                      isAvailable: student.isAvailable,
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudentProfileScreen(student: student),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildEmptyPlaceholder() {
    return Container(
      width: 260,
      margin: const EdgeInsets.only(right: 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      alignment: Alignment.center,
      child: const Text(
        'No student recommendations yet',
        style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
      ),
    );
  }
}
