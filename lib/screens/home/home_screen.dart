import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/explore_provider.dart';
import 'widgets/category_list_view.dart';
import 'widgets/greeting_header.dart';
import 'widgets/home_search_bar.dart';
import 'widgets/perfect_match_banner.dart';
import 'widgets/recommended_list_view.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback onExploreTap;
  final VoidCallback onProfileTap;

  const HomeScreen({
    super.key,
    required this.onExploreTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final explore = context.watch<ExploreProvider>();
    final auth = context.watch<AuthProvider>();
    final currentUid = auth.currentProfile.id;

    // Filter recommended students to exclude current user
    final recommended = explore.recommendedStudents
        .where((s) => s.id != currentUid)
        .toList();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(22, 12, 0, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting Header (User avatar, notification bell, greeting text)
          GreetingHeader(onProfileTap: onProfileTap),

          const SizedBox(height: 18),

          // Search Field
          HomeSearchBar(onTap: onExploreTap),

          const SizedBox(height: 20),

          // Explore Skills Category Chips
          CategoryListView(
            categories: ExploreProvider.categories,
            selectedIndex: explore.selectedCategoryIndex,
            onSelected: (index) {
              explore.setCategory(index);
              onExploreTap();
            },
          ),

          const SizedBox(height: 21),

          // Recommended for You Student Cards
          RecommendedListView(
            students: recommended,
            onSeeAll: onExploreTap,
          ),

          const SizedBox(height: 18),

          // Perfect Match Banner
          const PerfectMatchBanner(),
        ],
      ),
    );
  }
}
