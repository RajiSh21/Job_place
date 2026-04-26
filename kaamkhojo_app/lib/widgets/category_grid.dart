import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../utils/constants.dart';
import '../config/app_theme.dart';

class CategoryGrid extends StatelessWidget {
  final bool nepali;
  final String? selectedCategory;
  final ValueChanged<String>? onCategorySelected;

  const CategoryGrid({
    super.key,
    this.nepali = false,
    this.selectedCategory,
    this.onCategorySelected,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.85,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: serviceCategories.length,
      itemBuilder: (context, index) {
        final cat = serviceCategories[index];
        final isSelected = selectedCategory == cat.id;
        return _CategoryItem(
          category: cat,
          nepali: nepali,
          isSelected: isSelected,
          onTap: () {
            if (onCategorySelected != null) {
              onCategorySelected!(cat.id);
            } else {
              context.push('/search', extra: {'category': cat.id});
            }
          },
        );
      },
    );
  }
}

class _CategoryItem extends StatelessWidget {
  final ServiceCategory category;
  final bool nepali;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryItem({
    required this.category,
    required this.nepali,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withAlpha(26) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.divider,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.background,
                shape: BoxShape.circle,
              ),
              child: Icon(
                category.icon,
                color: isSelected ? Colors.white : AppColors.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              nepali ? category.labelNp : category.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
