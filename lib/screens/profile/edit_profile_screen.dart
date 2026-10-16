import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/widgets/avatar_widget.dart';
import '../../core/widgets/custom_button.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../models/user_profile.dart';
import '../../providers/auth_provider.dart';
import '../../services/profile_image_service.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({super.key, required this.profile});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _collegeController;
  late TextEditingController _departmentController;
  late TextEditingController _teachSkillInputController;
  late TextEditingController _teachSkillDescriptionController;
  late TextEditingController _learnSkillInputController;
  late String _selectedYear;
  late bool _isAvailable;
  late List<String> _skillsToTeach;
  late List<String> _skillsToLearn;
  late Map<String, String> _teachingSkillDescriptions;
  late String _photoUrl;
  bool _isUploadingPhoto = false;

  final List<String> _years = [
    '1st Year',
    '2nd Year',
    '3rd Year',
    '4th Year',
    'Postgraduate',
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profile.fullName);
    _bioController = TextEditingController(text: widget.profile.bio);
    _collegeController = TextEditingController(text: widget.profile.college);
    _departmentController = TextEditingController(
      text: widget.profile.department,
    );
    _teachSkillInputController = TextEditingController();
    _teachSkillDescriptionController = TextEditingController();
    _learnSkillInputController = TextEditingController();
    _selectedYear = _years.contains(widget.profile.year)
        ? widget.profile.year
        : _years.first;
    _isAvailable = widget.profile.isAvailable;
    _skillsToTeach = List<String>.from(widget.profile.skillsToTeach);
    _skillsToLearn = List<String>.from(widget.profile.skillsToLearn);
    _teachingSkillDescriptions = Map<String, String>.from(
      widget.profile.teachingSkillDescriptions,
    );
    _photoUrl = widget.profile.photoUrl;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _collegeController.dispose();
    _departmentController.dispose();
    _teachSkillInputController.dispose();
    _teachSkillDescriptionController.dispose();
    _learnSkillInputController.dispose();
    super.dispose();
  }

  void _addTeachSkill() {
    final name = _teachSkillInputController.text.trim();
    final description = _teachSkillDescriptionController.text.trim();
    if (name.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter both a skill name and your description.'),
        ),
      );
      return;
    }
    if (!_skillsToTeach.contains(name)) {
      setState(() {
        _skillsToTeach.add(name);
        _teachingSkillDescriptions[name] = description;
        _teachSkillInputController.clear();
        _teachSkillDescriptionController.clear();
      });
    } else {
      setState(() {
        _teachingSkillDescriptions[name] = description;
        _teachSkillDescriptionController.clear();
      });
    }
  }

  Future<void> _editTeachSkill(String skill) async {
    final descriptionController = TextEditingController(
      text: _teachingSkillDescriptions[skill] ?? '',
    );
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Describe $skill'),
        content: TextField(
          controller: descriptionController,
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'What can you teach in this skill?',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final description = descriptionController.text.trim();
              if (description.isNotEmpty) {
                setState(() => _teachingSkillDescriptions[skill] = description);
              }
              Navigator.pop(dialogContext);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
    // The dialog owns the TextField until its exit animation completes. Do not
    // dispose this short-lived controller here; disposing it immediately after
    // Navigator.pop can leave the TextField with active dependents.
  }

  void _addLearnSkill() {
    final text = _learnSkillInputController.text.trim();
    if (text.isNotEmpty && !_skillsToLearn.contains(text)) {
      setState(() {
        _skillsToLearn.add(text);
        _learnSkillInputController.clear();
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    final auth = context.read<AuthProvider>();
    final updated = widget.profile.copyWith(
      fullName: _nameController.text.trim(),
      bio: _bioController.text.trim(),
      college: _collegeController.text.trim(),
      department: _departmentController.text.trim(),
      year: _selectedYear,
      isAvailable: _isAvailable,
      skillsToTeach: _skillsToTeach,
      skillsToLearn: _skillsToLearn,
      teachingSkillDescriptions: _teachingSkillDescriptions,
      photoUrl: _photoUrl,
      updatedAt: DateTime.now(),
    );

    await auth.updateProfile(updated);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully! ✨'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.pop(context);
    }
  }

  Future<void> _changePhoto() async {
    final auth = context.read<AuthProvider>();
    final userId = auth.firebaseUser?.uid;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sign in before changing your profile photo.'),
        ),
      );
      return;
    }

    setState(() => _isUploadingPhoto = true);
    try {
      final url = await ProfileImageService().pickAndUpload(userId);
      if (url != null && mounted) {
        setState(() => _photoUrl = url);
      }
    } on FirebaseException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo upload failed: ${e.message ?? e.code}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Photo upload failed: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isUploadingPhoto = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Column(
                    children: [
                      AvatarWidget(
                        photoUrl: _photoUrl,
                        name: _nameController.text,
                        radius: 42,
                      ),
                      TextButton.icon(
                        onPressed: _isUploadingPhoto ? null : _changePhoto,
                        icon: _isUploadingPhoto
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.photo_library_outlined),
                        label: Text(
                          _isUploadingPhoto ? 'Uploading...' : 'Change photo',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                // Full Name
                CustomTextField(
                  controller: _nameController,
                  labelText: 'Full Name',
                  hintText: 'Your name',
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'Name is required'
                      : null,
                ),

                const SizedBox(height: 16),

                // Bio
                CustomTextField(
                  controller: _bioController,
                  labelText: 'Bio & About You',
                  hintText: 'Share what you enjoy learning or building...',
                  maxLines: 3,
                ),

                const SizedBox(height: 16),

                // College
                CustomTextField(
                  controller: _collegeController,
                  labelText: 'College / Institution',
                  hintText: 'College name',
                  validator: (val) => val == null || val.trim().isEmpty
                      ? 'College is required'
                      : null,
                ),

                const SizedBox(height: 16),

                // Department & Year
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: CustomTextField(
                        controller: _departmentController,
                        labelText: 'Department',
                        hintText: 'e.g. CSE',
                        validator: (val) => val == null || val.trim().isEmpty
                            ? 'Dept required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 3,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Year',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: AppColors.inputBackground,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedYear,
                                isExpanded: true,
                                icon: const Icon(
                                  Icons.keyboard_arrow_down_rounded,
                                  color: AppColors.textMuted,
                                ),
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textPrimary,
                                ),
                                items: _years.map((y) {
                                  return DropdownMenuItem(
                                    value: y,
                                    child: Text(y),
                                  );
                                }).toList(),
                                onChanged: (val) {
                                  if (val != null) {
                                    setState(() => _selectedYear = val);
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                // Availability Switch
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_outline_rounded,
                        color: AppColors.success,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Available for Exchanges',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                            Text(
                              'Allow other students to discover and request you',
                              style: TextStyle(
                                fontSize: 10,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch.adaptive(
                        value: _isAvailable,
                        activeTrackColor: AppColors.primary,
                        onChanged: (val) => setState(() => _isAvailable = val),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 22),

                // SKILLS TO TEACH CHIP MANAGER
                const Text(
                  'Skills You Can Teach 💡',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _teachSkillInputController,
                        hintText: 'Add a skill (e.g. Flutter, Figma)',
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      text: 'Add',
                      onPressed: _addTeachSkill,
                      height: 48,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                CustomTextField(
                  controller: _teachSkillDescriptionController,
                  labelText: 'Skill Description',
                  hintText: 'Explain what you can teach in this skill',
                  maxLines: 2,
                ),
                const SizedBox(height: 8),
                const SizedBox(height: 8),
                Column(
                  children: _skillsToTeach.map((skill) {
                    final description = _teachingSkillDescriptions[skill];
                    return Container(
                      width: double.infinity,
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppColors.primary.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  skill,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Text(
                                  description?.isNotEmpty == true
                                      ? description!
                                      : 'No description added yet.',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textBody,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_outlined, size: 18),
                            onPressed: () => _editTeachSkill(skill),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, size: 18),
                            onPressed: () => setState(() {
                              _skillsToTeach.remove(skill);
                              _teachingSkillDescriptions.remove(skill);
                            }),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 22),

                // SKILLS TO LEARN CHIP MANAGER
                const Text(
                  'Skills You Want to Learn 🎯',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _learnSkillInputController,
                        hintText: 'Add desired skill (e.g. Python, SQL)',
                      ),
                    ),
                    const SizedBox(width: 8),
                    CustomButton(
                      text: 'Add',
                      onPressed: _addLearnSkill,
                      height: 48,
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: _skillsToLearn.map((skill) {
                    return Chip(
                      label: Text(skill, style: const TextStyle(fontSize: 11)),
                      backgroundColor: const Color(0xFFEFFFF8),
                      deleteIcon: const Icon(Icons.close, size: 14),
                      onDeleted: () {
                        setState(() => _skillsToLearn.remove(skill));
                      },
                      side: const BorderSide(
                        color: AppColors.success,
                        width: 0.8,
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 32),

                // Save Button
                CustomButton(
                  text: 'Save Changes',
                  isLoading: auth.isLoading,
                  onPressed: _handleSave,
                  height: 50,
                  width: double.infinity,
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
