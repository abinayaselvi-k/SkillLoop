import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/custom_button.dart';
import '../../models/review.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../services/firestore_service.dart';
import '../../services/matching_service.dart';
import '../chat/chat_room_screen.dart';
import '../exchanges/create_request_dialog.dart';

class StudentProfileScreen extends StatelessWidget {
  final UserProfile student;

  const StudentProfileScreen({super.key, required this.student});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final currentUser = auth.currentProfile;
    final isSelf = currentUser.id == student.id;

    // Calculate match info
    final matchResult = MatchingService.evaluateMatch(
      currentUser: currentUser,
      candidate: student,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Student Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROFILE HEADER CARD
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.035),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Avatar with availability dot
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        AvatarWidget(
                          photoUrl: student.photoUrl,
                          name: student.fullName,
                          radius: 44,
                          borderWidth: 3,
                          borderColor: Colors.white,
                        ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            color: student.isAvailable
                                ? AppColors.success
                                : AppColors.textMuted,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Name
                    Text(
                      student.fullName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),

                    const SizedBox(height: 4),

                    // College & Dept
                    Text(
                      '${student.department} • ${student.year}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      student.college,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // STATS ROW
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.tagBackground,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _StatColumn(
                            icon: Icons.star_rounded,
                            iconColor: AppColors.warning,
                            value: student.averageRating.toStringAsFixed(1),
                            label: '${student.reviewCount} reviews',
                          ),
                          Container(
                            height: 28,
                            width: 1,
                            color: AppColors.border,
                          ),
                          _StatColumn(
                            icon: Icons.swap_horiz_rounded,
                            iconColor: AppColors.primary,
                            value: '${student.completedExchanges}',
                            label: 'Exchanges',
                          ),
                          Container(
                            height: 28,
                            width: 1,
                            color: AppColors.border,
                          ),
                          _StatColumn(
                            icon: Icons.circle,
                            iconColor: student.isAvailable
                                ? AppColors.success
                                : AppColors.textMuted,
                            value: student.isAvailable ? 'Available' : 'Busy',
                            label: 'Status',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              // SKILL MATCH SECTION (if overlap exists and not self)
              if (!isSelf && matchResult != null) ...[
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: AppColors.perfectMatchGradient,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primary.withValues(alpha: 0.18),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Text('✨', style: TextStyle(fontSize: 16)),
                          const SizedBox(width: 8),
                          Text(
                            matchResult.isMutual
                                ? 'Mutual Skill Match!'
                                : 'Skill Match Detected',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        matchResult.explanation,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textBody,
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
              ],

              // ABOUT SECTION
              if (student.bio.isNotEmpty) ...[
                const Text('About', style: AppTextStyles.sectionTitle),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(student.bio, style: AppTextStyles.body),
                ),
                const SizedBox(height: 18),
              ],

              // CAN TEACH SKILLS
              const Text('Can Teach 💡', style: AppTextStyles.sectionTitle),
              const SizedBox(height: 8),
              Column(
                children: student.skillsToTeach.map((skill) {
                  final matchesViewerWant = currentUser.skillsToLearn.any(
                    (s) => MatchingService.skillsMatch(s, skill),
                  );
                  final description = student.teachingSkillDescription(skill);

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: matchesViewerWant
                          ? AppColors.primaryLight
                          : Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: matchesViewerWant
                            ? AppColors.primary
                            : AppColors.border,
                        width: matchesViewerWant ? 1.4 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (matchesViewerWant) ...[
                              const Icon(
                                Icons.check_circle_rounded,
                                size: 14,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 5),
                            ],
                            Text(
                              skill,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: matchesViewerWant
                                    ? AppColors.primary
                                    : AppColors.textDark,
                              ),
                            ),
                          ],
                        ),
                        if (description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            description,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textBody,
                              height: 1.3,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 18),

              // WANTS TO LEARN SKILLS
              const Text(
                'Wants to Learn 🎯',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: student.skillsToLearn.map((skill) {
                  final matchesViewerTeach = currentUser.skillsToTeach.any(
                    (s) => MatchingService.skillsMatch(s, skill),
                  );

                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: matchesViewerTeach
                          ? const Color(0xFFEFFFF8)
                          : AppColors.tagBackground,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: matchesViewerTeach
                            ? AppColors.success
                            : AppColors.border,
                        width: matchesViewerTeach ? 1.4 : 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (matchesViewerTeach) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 5),
                        ],
                        Text(
                          skill,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: matchesViewerTeach
                                ? AppColors.successDark
                                : AppColors.textBody,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // ACTION BUTTONS (Only if not viewing own profile)
              if (!isSelf) ...[
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomButton(
                        text: 'Request Exchange',
                        icon: Icons.swap_horiz_rounded,
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => CreateRequestDialog(peer: student),
                          );
                        },
                        height: 48,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: CustomButton(
                        text: 'Start Chat',
                        icon: Icons.chat_bubble_outline_rounded,
                        variant: ButtonVariant.secondary,
                        onPressed: () async {
                          final chat = context.read<ChatProvider>();
                          final convId = await chat.startConversation(
                            currentUserId: currentUser.id,
                            otherUserId: student.id,
                            currentUserName: currentUser.fullName,
                            otherUserName: student.fullName,
                            currentUserPhoto: currentUser.photoUrl,
                            otherUserPhoto: student.photoUrl,
                          );

                          if (context.mounted) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ChatRoomScreen(
                                  conversationId: convId,
                                  recipientId: student.id,
                                  recipientName: student.fullName,
                                  recipientPhoto: student.photoUrl,
                                ),
                              ),
                            );
                          }
                        },
                        height: 48,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
              ],

              // RECENT REVIEWS
              const Text(
                'Student Reviews & Feedback',
                style: AppTextStyles.sectionTitle,
              ),
              const SizedBox(height: 10),
              _ReviewsSection(studentId: student.id),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  const _StatColumn({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconColor),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
        ),
      ],
    );
  }
}

class _ReviewsSection extends StatelessWidget {
  final String studentId;

  const _ReviewsSection({required this.studentId});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: FirestoreService().streamUserReviews(studentId),
      builder: (context, snapshot) {
        final reviews = snapshot.data ?? [];

        if (reviews.isEmpty) {
          return Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: const Text(
              'No peer reviews yet. Complete an exchange session to leave the first review!',
              style: TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: reviews.length,
          separatorBuilder: (context, index) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final rev = reviews[index];
            return Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      AvatarWidget(
                        photoUrl: rev.reviewerPhotoUrl,
                        name: rev.reviewerName,
                        radius: 14,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        rev.reviewerName,
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const Spacer(),
                      const Icon(
                        Icons.star_rounded,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        rev.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                  if (rev.comment.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      rev.comment,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textBody,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }
}
