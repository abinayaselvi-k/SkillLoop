import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../providers/exchange_provider.dart';

class CreateRequestDialog extends StatefulWidget {
  final UserProfile peer;

  const CreateRequestDialog({super.key, required this.peer});

  @override
  State<CreateRequestDialog> createState() => _CreateRequestDialogState();
}

class _CreateRequestDialogState extends State<CreateRequestDialog> {
  final _messageController = TextEditingController();
  String? _selectedOfferedSkill;
  String? _selectedRequestedSkill;

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    final currentUser = auth.currentProfile;

    if (currentUser.skillsToTeach.isNotEmpty) {
      _selectedOfferedSkill = currentUser.skillsToTeach.first;
    }
    if (widget.peer.skillsToTeach.isNotEmpty) {
      _selectedRequestedSkill = widget.peer.skillsToTeach.first;
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _handleSend() async {
    if (_selectedOfferedSkill == null || _selectedRequestedSkill == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both an offered and requested skill.'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final auth = context.read<AuthProvider>();
    final exchange = context.read<ExchangeProvider>();
    final currentUser = auth.currentProfile;

    final success = await exchange.sendRequest(
      senderId: currentUser.id,
      receiverId: widget.peer.id,
      senderName: currentUser.fullName,
      receiverName: widget.peer.fullName,
      senderPhotoUrl: currentUser.photoUrl,
      receiverPhotoUrl: widget.peer.photoUrl,
      offeredSkill: _selectedOfferedSkill!,
      requestedSkill: _selectedRequestedSkill!,
      message: _messageController.text.trim(),
    );

    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exchange request sent to ${widget.peer.fullName}! 🚀'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (exchange.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(exchange.errorMessage!),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final exchange = context.watch<ExchangeProvider>();
    final currentUser = auth.currentProfile;

    final offeredSkills = currentUser.skillsToTeach.isNotEmpty
        ? currentUser.skillsToTeach
        : ['General Skills'];
    final requestedSkills = widget.peer.skillsToTeach.isNotEmpty
        ? widget.peer.skillsToTeach
        : ['General Skills'];

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      backgroundColor: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.swap_horiz_rounded,
                        color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Propose Skill Exchange',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        Text(
                          'with ${widget.peer.fullName}',
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

              const SizedBox(height: 18),

              // Skill you offer
              const Text(
                'Skill You Will Teach / Offer',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOfferedSkill,
                    isExpanded: true,
                    items: offeredSkills.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedOfferedSkill = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Skill you want
              Text(
                'Skill You Want From ${widget.peer.fullName.split(' ').first}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                height: 46,
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedRequestedSkill,
                    isExpanded: true,
                    items: requestedSkills.map((s) {
                      return DropdownMenuItem(value: s, child: Text(s));
                    }).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => _selectedRequestedSkill = val);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // Message
              CustomTextField(
                controller: _messageController,
                labelText: 'Add a Message (Optional)',
                hintText: 'e.g. Would love to swap 1hr of Figma for Python basics!',
                maxLines: 2,
              ),

              const SizedBox(height: 22),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: CustomButton(
                      text: 'Cancel',
                      variant: ButtonVariant.outline,
                      height: 44,
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: CustomButton(
                      text: 'Send',
                      isLoading: exchange.isLoading,
                      height: 44,
                      onPressed: _handleSend,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
