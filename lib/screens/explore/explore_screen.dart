import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/widgets/category_chip.dart';
import '../../core/widgets/empty_state_view.dart';
import '../../core/widgets/student_card.dart';
import '../../providers/auth_provider.dart';
import '../../providers/explore_provider.dart';
import '../profile/student_profile_screen.dart';

class ExploreScreen extends StatefulWidget {
  final VoidCallback? onGoHome;

  const ExploreScreen({super.key, this.onGoHome});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _searchController = TextEditingController();

  final List<String> _departments = [
    'All Departments',
    'CSE',
    'ECE',
    'IT',
    'Mech',
    'Management',
  ];

  @override
  void initState() {
    super.initState();
    final explore = context.read<ExploreProvider>();
    _searchController.text = explore.searchQuery;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final explore = context.watch<ExploreProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUid = auth.currentProfile.id;

    // Filter out current user
    final students = explore.filteredStudents
        .where((s) => s.id != currentUid)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Explore Skills & Peers'),
        actions: [
          IconButton(
            onPressed: widget.onGoHome,
            tooltip: 'Go to Home',
            icon: const Icon(Icons.home_outlined),
          ),
          if (explore.searchQuery.isNotEmpty ||
              explore.selectedCategoryIndex != -1 ||
              explore.selectedDepartment != null)
            TextButton(
              onPressed: () {
                _searchController.clear();
                explore.clearFilters();
              },
              child: const Text(
                'Reset',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) => explore.setSearchQuery(val),
                  decoration: InputDecoration(
                    hintText: 'Search by skill, name, or topic...',
                    hintStyle: const TextStyle(
                      fontSize: 12,
                      color: AppColors.textMuted,
                    ),
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                      size: 20,
                      color: AppColors.textMuted,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _searchController.clear();
                              explore.setSearchQuery('');
                            },
                          )
                        : null,
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 13),
                  ),
                ),
              ),
            ),

            // Category Chips
            SizedBox(
              height: 38,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: ExploreProvider.categories.length,
                separatorBuilder: (context, index) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  return CategoryChip(
                    label: ExploreProvider.categories[index],
                    isSelected: explore.selectedCategoryIndex == index,
                    onTap: () => explore.setCategory(index),
                  );
                },
              ),
            ),

            const SizedBox(height: 10),

            // Department Filters
            SizedBox(
              height: 32,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: _departments.length,
                separatorBuilder: (context, index) => const SizedBox(width: 6),
                itemBuilder: (context, index) {
                  final dept = _departments[index];
                  final isAll = index == 0;
                  final isSelected = isAll
                      ? (explore.selectedDepartment == null ||
                            explore.selectedDepartment!.isEmpty)
                      : (explore.selectedDepartment == dept);

                  return GestureDetector(
                    onTap: () {
                      explore.setDepartment(isAll ? null : dept);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppColors.primarySoft
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.border,
                          width: 1,
                        ),
                      ),
                      child: Text(
                        dept,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textBody,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 12),

            // Results count
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                '${students.length} Student${students.length == 1 ? '' : 's'} Available',
                style: AppTextStyles.bodySmall,
              ),
            ),

            const SizedBox(height: 8),

            // Students Grid
            Expanded(
              child: students.isEmpty
                  ? EmptyStateView(
                      icon: Icons.search_off_rounded,
                      title: 'No matching students',
                      message:
                          'Try searching for different skill keywords or clearing your active filters.',
                      actionText: 'Clear Filters',
                      onAction: () {
                        _searchController.clear();
                        explore.clearFilters();
                      },
                    )
                  : GridView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                      physics: const BouncingScrollPhysics(),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.76,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 14,
                          ),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return StudentCard(
                          name: student.fullName,
                          course: student.courseInfo,
                          skill: student.primaryTeachingSkill,
                          tags: student.skillsToTeach,
                          rating: student.averageRating.toStringAsFixed(1),
                          avatar: student.photoUrl,
                          isAvailable: student.isAvailable,
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) =>
                                    StudentProfileScreen(student: student),
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
