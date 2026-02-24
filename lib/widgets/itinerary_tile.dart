// lib/widgets/itinerary_tile.dart
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../utils/helpers.dart';

class ItineraryTile extends StatelessWidget {
  final Place place;
  final int index;
  final Color slotColor;
  final bool isEditing;
  final VoidCallback? onRemove;

  const ItineraryTile({
    super.key,
    required this.place,
    required this.index,
    required this.slotColor,
    this.isEditing = false,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
        '${capitalize(place.category)} · ${priceLevelToString(place.priceLevel)} · ⭐ ${place.rating.toStringAsFixed(1)}',
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
