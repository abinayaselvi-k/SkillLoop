import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:skillloop_ui/skillloop_ui.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../models/exchange_request.dart';
import '../../providers/auth_provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/exchange_provider.dart';
import '../chat/chat_room_screen.dart';
import '../reviews/submit_review_dialog.dart';

class ExchangeRequestsScreen extends StatefulWidget {
  const ExchangeRequestsScreen({super.key});

  @override
  State<ExchangeRequestsScreen> createState() => _ExchangeRequestsScreenState();
}

class _ExchangeRequestsScreenState extends State<ExchangeRequestsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exchange = context.watch<ExchangeProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUserId = auth.currentProfile.id;

    final received = exchange.receivedRequests;
    final sent = exchange.sentRequests;
    final completed = [
      ...received.where((r) => r.status == ExchangeStatus.completed),
      ...sent.where((r) => r.status == ExchangeStatus.completed),
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Skill Exchange Requests'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 2.5,
          labelStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Received (${received.length})'),
            Tab(text: 'Sent (${sent.length})'),
            Tab(text: 'Completed (${completed.length})'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Received Tab
          _buildRequestList(
            requests: received,
            isReceived: true,
            currentUserId: currentUserId,
            emptyTitle: 'No Requests Received',
            emptyMessage: 'When other students want to exchange skills with you, their requests will appear here.',
          ),

          // Sent Tab
          _buildRequestList(
            requests: sent,
            isReceived: false,
            currentUserId: currentUserId,
            emptyTitle: 'No Requests Sent',
            emptyMessage: 'Explore student profiles or matches to send your first skill exchange proposal!',
          ),

          // Completed Tab
          _buildCompletedList(
            requests: completed,
            currentUserId: currentUserId,
          ),
        ],
      ),
    );
  }

  Widget _buildRequestList({
    required List<ExchangeRequest> requests,
    required bool isReceived,
    required String currentUserId,
    required String emptyTitle,
    required String emptyMessage,
  }) {
    if (requests.isEmpty) {
      return EmptyStateView(
        icon: Icons.swap_horiz_rounded,
        title: emptyTitle,
        message: emptyMessage,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final req = requests[index];
        return _RequestCard(
          request: req,
          isReceived: isReceived,
          currentUserId: currentUserId,
        );
      },
    );
  }

  Widget _buildCompletedList({
    required List<ExchangeRequest> requests,
    required String currentUserId,
  }) {
    if (requests.isEmpty) {
      return const EmptyStateView(
        icon: Icons.check_circle_outline_rounded,
        title: 'No Completed Exchanges Yet',
        message: 'After an accepted session takes place, mark it as completed to unlock reviews and reputation.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(20),
      physics: const BouncingScrollPhysics(),
      itemCount: requests.length,
      separatorBuilder: (context, index) => const SizedBox(height: 14),
      itemBuilder: (context, index) {
        final req = requests[index];
        final otherId = req.senderId == currentUserId ? req.receiverId : req.senderId;
        final otherName = req.senderId == currentUserId ? req.receiverName : req.senderName;
        final otherPhoto = req.senderId == currentUserId ? req.receiverPhotoUrl : req.senderPhotoUrl;

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  AvatarWidget(photoUrl: otherPhoto, name: otherName, radius: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          otherName,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'Exchanged: ${req.offeredSkill} ⇄ ${req.requestedSkill}',
                          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  const SkillLoopStatusBadge(
                    label: 'Completed',
                    foregroundColor: AppColors.successDark,
                    backgroundColor: Color(0xFFEFFFF8),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              CustomButton(
                text: 'Leave Rating & Review ⭐',
                variant: ButtonVariant.secondary,
                height: 38,
                borderRadius: 10,
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (_) => SubmitReviewDialog(
                      exchange: req,
                      revieweeId: otherId,
                      revieweeName: otherName,
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _RequestCard extends StatelessWidget {
  final ExchangeRequest request;
  final bool isReceived;
  final String currentUserId;

  const _RequestCard({
    required this.request,
    required this.isReceived,
    required this.currentUserId,
  });

  Color _getStatusColor(ExchangeStatus status) {
    switch (status) {
      case ExchangeStatus.pending:
        return AppColors.warning;
      case ExchangeStatus.accepted:
        return AppColors.success;
      case ExchangeStatus.rejected:
        return AppColors.error;
      case ExchangeStatus.completed:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final exchange = context.read<ExchangeProvider>();
    final chat = context.read<ChatProvider>();
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentProfile;

    final otherName = isReceived ? request.senderName : request.receiverName;
    final otherPhoto = isReceived ? request.senderPhotoUrl : request.receiverPhotoUrl;
    final otherId = isReceived ? request.senderId : request.receiverId;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
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
          // Header
          Row(
            children: [
              AvatarWidget(photoUrl: otherPhoto, name: otherName, radius: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      otherName,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    Text(
                      isReceived ? 'wants to exchange skills' : 'request sent',
                      style: const TextStyle(fontSize: 10, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
              SkillLoopStatusBadge(
                label: request.status.label,
                foregroundColor: _getStatusColor(request.status),
                backgroundColor:
                    _getStatusColor(request.status).withValues(alpha: 0.15),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Skill Trade Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.tagBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'OFFERING',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.offeredSkill,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.primary),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.swap_horiz_rounded, size: 20, color: AppColors.primary),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text(
                        'REQUESTING',
                        style: TextStyle(fontSize: 8, fontWeight: FontWeight.w700, color: AppColors.textMuted),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        request.requestedSkill,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.successDark),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          if (request.message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              '"${request.message}"',
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.textBody,
              ),
            ),
          ],

          const SizedBox(height: 14),

          // Action Buttons depending on status & role
          if (isReceived && request.status == ExchangeStatus.pending) ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Decline',
                    variant: ButtonVariant.outline,
                    height: 38,
                    borderRadius: 10,
                    onPressed: () => exchange.rejectRequest(request),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Accept Exchange',
                    height: 38,
                    borderRadius: 10,
                    onPressed: () => exchange.acceptRequest(request),
                  ),
                ),
              ],
            ),
          ] else if (request.status == ExchangeStatus.accepted) ...[
            Row(
              children: [
                Expanded(
                  child: CustomButton(
                    text: 'Start Chat',
                    icon: Icons.chat_bubble_outline_rounded,
                    height: 38,
                    borderRadius: 10,
                    onPressed: () async {
                      final convId = await chat.startConversation(
                        currentUserId: currentUser.id,
                        otherUserId: otherId,
                        currentUserName: currentUser.fullName,
                        otherUserName: otherName,
                        currentUserPhoto: currentUser.photoUrl,
                        otherUserPhoto: otherPhoto,
                        relatedRequestId: request.id,
                      );

                      if (context.mounted) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => ChatRoomScreen(
                              conversationId: convId,
                              recipientId: otherId,
                              recipientName: otherName,
                              recipientPhoto: otherPhoto,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: CustomButton(
                    text: 'Mark Completed',
                    variant: ButtonVariant.secondary,
                    height: 38,
                    borderRadius: 10,
                    onPressed: () => exchange.completeExchange(request, currentUserId),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
