import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../models/app_notification.dart';
import '../../providers/notification_provider.dart';
import '../exchanges/exchange_requests_screen.dart';
import '../chat/conversations_screen.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  IconData _getIcon(NotificationType type) {
    switch (type) {
      case NotificationType.requestReceived:
        return Icons.swap_horiz_rounded;
      case NotificationType.requestAccepted:
        return Icons.celebration_rounded;
      case NotificationType.requestRejected:
        return Icons.cancel_outlined;
      case NotificationType.newMessage:
        return Icons.chat_bubble_outline_rounded;
      case NotificationType.exchangeCompleted:
        return Icons.check_circle_rounded;
      case NotificationType.reviewReceived:
        return Icons.star_rounded;
    }
  }

  Color _getColor(NotificationType type) {
    switch (type) {
      case NotificationType.requestReceived:
      case NotificationType.newMessage:
        return AppColors.primary;
      case NotificationType.requestAccepted:
      case NotificationType.exchangeCompleted:
        return AppColors.success;
      case NotificationType.requestRejected:
        return AppColors.error;
      case NotificationType.reviewReceived:
        return AppColors.warning;
    }
  }

  @override
  Widget build(BuildContext context) {
    final notifProvider = context.watch<NotificationProvider>();
    final notifications = notifProvider.notifications;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Notifications 🔔'),
      ),
      body: SafeArea(
        child: notifications.isEmpty
            ? const EmptyStateView(
                icon: Icons.notifications_none_rounded,
                title: 'No Notifications Yet',
                message:
                    'You\'re all caught up! When you receive requests, messages, or reviews, they will appear here.',
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                physics: const BouncingScrollPhysics(),
                itemCount: notifications.length,
                separatorBuilder: (context, index) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final notif = notifications[index];
                  final icon = _getIcon(notif.type);
                  final color = _getColor(notif.type);

                  String time = '';
                  if (notif.createdAt != null) {
                    time = DateFormat('MMM d, h:mm a').format(notif.createdAt!);
                  }

                  return InkWell(
                    onTap: () async {
                      if (!notif.isRead) {
                        await notifProvider.markAsRead(notif.id);
                      }
                      if (context.mounted) {
                        if (notif.type == NotificationType.newMessage) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ConversationsScreen(),
                            ),
                          );
                        } else if (notif.type == NotificationType.requestReceived ||
                            notif.type == NotificationType.requestAccepted ||
                            notif.type == NotificationType.requestRejected ||
                            notif.type == NotificationType.exchangeCompleted) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ExchangeRequestsScreen(),
                            ),
                          );
                        }
                      }
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: notif.isRead ? Colors.white : AppColors.primaryLight.withValues(alpha: 0.35),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: notif.isRead
                              ? AppColors.border
                              : AppColors.primary.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(icon, color: color, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        notif.title,
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: notif.isRead
                                              ? FontWeight.w700
                                              : FontWeight.w800,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    if (!notif.isRead)
                                      Container(
                                        width: 8,
                                        height: 8,
                                        decoration: const BoxDecoration(
                                          color: AppColors.primary,
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  notif.body,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                    height: 1.3,
                                  ),
                                ),
                                if (time.isNotEmpty) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    time,
                                    style: const TextStyle(
                                      fontSize: 9,
                                      color: AppColors.textMuted,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
