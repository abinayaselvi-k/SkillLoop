import 'package:flutter/material.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/widgets/category_chip.dart';

class CategoryListView extends StatelessWidget {
  final List<String> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  const CategoryListView({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore Skills',
          style: AppTextStyles.sectionTitle,
        ),
        const SizedBox(height: 11),
        SizedBox(
          height: 38,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(right: 22),
            itemCount: categories.length,
            separatorBuilder: (context, index) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              return CategoryChip(
                label: categories[index],
                isSelected: selectedIndex == index,
                onTap: () => onSelected(index),
              );
            },
          ),
        ),
      ],
    );
  }
}
