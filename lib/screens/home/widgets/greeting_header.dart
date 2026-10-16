import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/avatar_widget.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/notification_provider.dart';
import '../../notifications/notifications_screen.dart';

class GreetingHeader extends StatelessWidget {
  final VoidCallback onProfileTap;

  const GreetingHeader({
    super.key,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final notifProvider = context.watch<NotificationProvider>();
    final profile = auth.currentProfile;

    // Get first name
    final firstName = profile.fullName.trim().split(RegExp(r'\s+')).first;
    final displayName = firstName.isNotEmpty ? firstName : 'Student';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Top Row: Spacer, Notification Icon, Profile Avatar
        Padding(
          padding: const EdgeInsets.only(right: 22),
          child: Row(
            children: [
              const Spacer(),

              // Notification Bell
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const NotificationsScreen(),
                    ),
                  );
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.borderLight),
                      ),
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 22,
                        color: Color(0xFF374151),
                      ),
                    ),
                    if (notifProvider.unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.error,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            notifProvider.unreadCount > 9
                                ? '9+'
                                : '${notifProvider.unreadCount}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // User Profile Avatar
              GestureDetector(
                onTap: onProfileTap,
                child: AvatarWidget(
                  photoUrl: profile.photoUrl,
                  name: profile.fullName,
                  radius: 21,
                  borderWidth: 2,
                  borderColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Greeting
        Text(
          'Hi, $displayName! 👋',
          style: AppTextStyles.heading1,
        ),

        const SizedBox(height: 3),

        const Text(
          'What do you want to learn today?',
          style: AppTextStyles.subtitle,
        ),
      ],
    );
  }
}
