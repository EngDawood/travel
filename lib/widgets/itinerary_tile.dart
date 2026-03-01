// lib/widgets/itinerary_tile.dart
import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/place.dart';
import '../utils/helpers.dart';

class ItineraryTile extends StatelessWidget {
  final Place place;
  final int index;
  final Color slotColor;
  final bool isEditing;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const ItineraryTile({
    super.key,
    required this.place,
    required this.index,
    required this.slotColor,
    this.isEditing = false,
    this.onRemove,
    this.onTap,
  });

  String _localizedCategory(AppLocalizations l10n, String cat) {
    switch (cat) {
      case 'restaurant':
        return l10n.catRestaurant;
      case 'cafe':
        return l10n.catCafe;
      case 'attraction':
        return l10n.catAttraction;
      case 'shopping':
        return l10n.catShopping;
      case 'nightlife':
        return l10n.catNightlife;
      default:
        return capitalize(cat);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final priceStr = place.priceLevel == 0
        ? l10n.placeDetailFree
        : '\$' * place.priceLevel;
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: CircleAvatar(
        backgroundColor: slotColor.withValues(alpha: 0.15),
        child: Text(
          '$index',
          style: TextStyle(
            color: slotColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        place.name,
        style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
      ),
      subtitle: Text(
        '${_localizedCategory(l10n, place.category)} · $priceStr · ⭐ ${place.rating.toStringAsFixed(1)}',
        style: const TextStyle(fontSize: 12),
      ),
      trailing: isEditing
          ? IconButton(
              icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
              onPressed: onRemove,
            )
          : Icon(Icons.chevron_right, color: Colors.grey[400]),
    );
  }
}
