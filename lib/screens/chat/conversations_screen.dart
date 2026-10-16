import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import 'chat_room_screen.dart';

class ConversationsScreen extends StatelessWidget {
  final VoidCallback? onGoHome;

  const ConversationsScreen({super.key, this.onGoHome});

  @override
  Widget build(BuildContext context) {
    final chat = context.watch<ChatProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentProfile.id;

    final conversations = chat.conversations;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Messages 💬'),
        actions: [
          TextButton.icon(
            onPressed: onGoHome,
            icon: const Icon(Icons.home_outlined, size: 18),
            label: const Text('Home'),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.primary,
              textStyle: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: conversations.isEmpty
            ? const EmptyStateView(
                icon: Icons.chat_bubble_outline_rounded,
                title: 'No Conversations Yet',
                message:
                    'Connect with peers by requesting a skill exchange or starting a conversation from their student profile.',
              )
            : ListView.separated(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                physics: const BouncingScrollPhysics(),
                itemCount: conversations.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final conv = conversations[index];
                  final otherId = conv.getOtherUserId(currentUserId);
                  final otherName = conv.getOtherUserName(currentUserId);
                  final otherPhoto = conv.getOtherUserPhoto(currentUserId);

                  String timeText = '';
                  if (conv.lastMessageAt != null) {
                    final now = DateTime.now();
                    final diff = now.difference(conv.lastMessageAt!);
                    if (diff.inDays == 0) {
                      timeText = DateFormat(
                        'h:mm a',
                      ).format(conv.lastMessageAt!);
                    } else if (diff.inDays < 7) {
                      timeText = DateFormat('E').format(conv.lastMessageAt!);
                    } else {
                      timeText = DateFormat(
                        'MMM d',
                      ).format(conv.lastMessageAt!);
                    }
                  }

                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatRoomScreen(
                            conversationId: conv.id,
                            recipientId: otherId,
                            recipientName: otherName,
                            recipientPhoto: otherPhoto,
                          ),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.025),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          AvatarWidget(
                            photoUrl: otherPhoto,
                            name: otherName,
                            radius: 24,
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
                                        otherName,
                                        style: const TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w800,
                                          color: AppColors.textDark,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      timeText,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        color: AppColors.textMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  conv.lastMessage.isNotEmpty
                                      ? conv.lastMessage
                                      : 'Tap to chat',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
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
