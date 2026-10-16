import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../providers/auth_provider.dart';
import '../../providers/explore_provider.dart';
import '../../services/matching_service.dart';
import '../exchanges/create_request_dialog.dart';
import '../profile/edit_profile_screen.dart';
import '../profile/student_profile_screen.dart';

class ExploreMatchesScreen extends StatelessWidget {
  const ExploreMatchesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final explore = context.watch<ExploreProvider>();
    final currentUser = auth.currentProfile;

    // Calculate matches
    final matches = MatchingService.calculateMatches(
      currentUser: currentUser,
      candidates: explore.allStudents,
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Your Skill Matches ✨'),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header summary banner
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: AppColors.perfectMatchGradient,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Text('💡', style: TextStyle(fontSize: 22)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'How Matching Works',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'We compare your learning wishlist (${currentUser.skillsToLearn.join(", ")}) with peer skillsets.',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Matches List
            Expanded(
              child: matches.isEmpty
                  ? EmptyStateView(
                      icon: Icons.auto_awesome_rounded,
                      title: 'No Direct Matches Yet',
                      message:
                          'Add more skills you want to learn in your profile to discover matching peers.',
                      actionText: 'Update My Skills',
                      onAction: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EditProfileScreen(profile: currentUser),
                          ),
                        );
                      },
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      itemCount: matches.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final match = matches[index];
                        return _MatchCard(match: match);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MatchCard extends StatelessWidget {
  final SkillMatchResult match;

  const _MatchCard({required this.match});

  @override
  Widget build(BuildContext context) {
    final peer = match.peer;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: match.isMutual ? AppColors.primary.withValues(alpha: 0.4) : AppColors.border,
          width: match.isMutual ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Peer Header
          Row(
            children: [
              AvatarWidget(
                photoUrl: peer.photoUrl,
                name: peer.fullName,
                radius: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            peer.fullName,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                        ),
                        if (match.isMutual) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'MUTUAL MATCH',
                              style: TextStyle(
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${peer.department} • ${peer.year}',
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.star_rounded, size: 14, color: AppColors.warning),
                  const SizedBox(width: 2),
                  Text(
                    peer.averageRating.toStringAsFixed(1),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Match Explanation Pill
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.tagBackground,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              match.explanation,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textDark,
                height: 1.3,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Skill Breakdown
          if (match.theyCanTeachYou.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.check_circle_rounded, size: 14, color: AppColors.primary),
                const SizedBox(width: 6),
                const Text(
                  'They Can Teach You: ',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  match.theyCanTeachYou.join(', '),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.primary),
                ),
              ],
            ),
            const SizedBox(height: 4),
          ],

          if (match.youCanTeachThem.isNotEmpty) ...[
            Row(
              children: [
                const Icon(Icons.star_rounded, size: 14, color: AppColors.success),
                const SizedBox(width: 6),
                const Text(
                  'You Can Teach Them: ',
                  style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.textDark),
                ),
                Text(
                  match.youCanTeachThem.join(', '),
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.successDark),
                ),
              ],
            ),
          ],

          const SizedBox(height: 14),

          // Actions
          Row(
            children: [
              Expanded(
                child: CustomButton(
                  text: 'Request Exchange',
                  height: 36,
                  borderRadius: 10,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => CreateRequestDialog(peer: peer),
                    );
                  },
                ),
              ),
              const SizedBox(width: 10),
              CustomButton(
                text: 'View Profile',
                variant: ButtonVariant.secondary,
                height: 36,
                borderRadius: 10,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => StudentProfileScreen(student: peer),
                    ),
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
