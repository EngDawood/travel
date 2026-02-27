// lib/widgets/itinerary_tile.dart (list tile for saved itineraries list)
import 'package:flutter/material.dart';

import '../models/itinerary.dart';
import '../utils/helpers.dart';

class SavedItineraryTile extends StatelessWidget {
  final Itinerary itinerary;
  final VoidCallback onTap;
  final VoidCallback? onDelete;

  const SavedItineraryTile({
    super.key,
    required this.itinerary,
    required this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final placeCount = itinerary.places.length;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
          child: Icon(Icons.map,
              color: Theme.of(context).colorScheme.primary),
        ),
        title: Text(
          itinerary.name.isEmpty ? itinerary.city : itinerary.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          '${itinerary.city} · ${formatDate(itinerary.date)} · $placeCount places',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: onDelete != null
            ? IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.red),
                onPressed: onDelete,
              )
            : null,
        onTap: onTap,
      ),
    );
  }
}
