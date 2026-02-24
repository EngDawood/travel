// lib/widgets/category_chip.dart
import 'package:flutter/material.dart';

import '../config/constants.dart';

/// Icons for each place category.
const _categoryIcons = {
  PlaceCategory.restaurant: Icons.restaurant,
  PlaceCategory.cafe: Icons.local_cafe,
  PlaceCategory.attraction: Icons.attractions,
  PlaceCategory.shopping: Icons.shopping_bag,
  PlaceCategory.nightlife: Icons.nightlife,
};

class CategoryChip extends StatelessWidget {
  final PlaceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.white,
          border: Border.all(color: isSelected ? color : Colors.grey[300]!),
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [BoxShadow(color: color.withValues(alpha: 0.3), blurRadius: 6)]
              : [],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _categoryIcons[category] ?? Icons.place,
              color: isSelected ? Colors.white : Colors.grey[700],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              category.displayName,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[800],
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
