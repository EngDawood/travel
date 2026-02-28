// lib/widgets/preference_category_card.dart
import 'package:flutter/material.dart';

import '../config/constants.dart';
import '../l10n/generated/app_localizations.dart';

class PreferenceCategoryCard extends StatelessWidget {
  final PlaceCategory category;
  final bool isSelected;
  final VoidCallback onTap;

  const PreferenceCategoryCard({
    super.key,
    required this.category,
    required this.isSelected,
    required this.onTap,
  });

  String _localizedDisplayName(AppLocalizations l10n) {
    switch (category) {
      case PlaceCategory.restaurant:
        return l10n.categoryRestaurants;
      case PlaceCategory.cafe:
        return l10n.categoryCafes;
      case PlaceCategory.attraction:
        return l10n.categoryAttractions;
      case PlaceCategory.shopping:
        return l10n.categoryShopping;
      case PlaceCategory.nightlife:
        return l10n.categoryNightlife;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)
                : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Category icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _iconBackgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(_iconEmoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: 16),
            // Category name
            Expanded(
              child: Text(
                _localizedDisplayName(l10n),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Toggle circle
            Icon(
              isSelected
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[400],
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  String get _iconEmoji {
    switch (category) {
      case PlaceCategory.restaurant:
        return '\u{1F374}'; // fork and knife
      case PlaceCategory.cafe:
        return '\u{2615}'; // hot beverage
      case PlaceCategory.attraction:
        return '\u{1F3DB}'; // classical building
      case PlaceCategory.shopping:
        return '\u{1F6CD}'; // shopping bags
      case PlaceCategory.nightlife:
        return '\u{1F319}'; // crescent moon
    }
  }

  Color get _iconBackgroundColor {
    switch (category) {
      case PlaceCategory.restaurant:
        return const Color(0xFFFFF3E0); // orange light
      case PlaceCategory.cafe:
        return const Color(0xFFFFF9C4); // yellow light
      case PlaceCategory.attraction:
        return const Color(0xFFE3F2FD); // blue light
      case PlaceCategory.shopping:
        return const Color(0xFFFFEBEE); // red light
      case PlaceCategory.nightlife:
        return const Color(0xFFF3E5F5); // purple light
    }
  }
}
