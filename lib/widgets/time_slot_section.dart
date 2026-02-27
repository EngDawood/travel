// lib/widgets/time_slot_section.dart
import 'package:flutter/material.dart';

import '../models/place.dart';
import '../utils/helpers.dart';
import '../widgets/itinerary_tile.dart';

class TimeSlotSection extends StatelessWidget {
  final String slot;
  final List<Place> places;
  final bool isEditing;
  final void Function(Place)? onRemove;
  final void Function(Place)? onPlaceTap;

  const TimeSlotSection({
    super.key,
    required this.slot,
    required this.places,
    this.isEditing = false,
    this.onRemove,
    this.onPlaceTap,
  });

  IconData get _icon {
    switch (slot) {
      case 'morning':
        return Icons.wb_sunny;
      case 'afternoon':
        return Icons.wb_cloudy;
      case 'evening':
        return Icons.nights_stay;
      default:
        return Icons.schedule;
    }
  }

  Color get _color {
    switch (slot) {
      case 'morning':
        return Colors.orange;
      case 'afternoon':
        return Colors.blue;
      case 'evening':
        return Colors.indigo;
      default:
        return Colors.grey;
    }
  }

  String get _timeRange {
    switch (slot) {
      case 'morning':
        return '8:00 AM – 12:00 PM';
      case 'afternoon':
        return '12:00 PM – 5:00 PM';
      case 'evening':
        return '5:00 PM – 10:00 PM';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Slot header
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: _color.withValues(alpha: 0.08),
          child: Row(
            children: [
              Icon(_icon, color: _color, size: 20),
              const SizedBox(width: 8),
              Text(
                capitalize(slot),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: _color,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                _timeRange,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        if (places.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              'No places assigned to this slot.',
              style: TextStyle(color: Colors.grey[500], fontSize: 13),
            ),
          )
        else
          ...places.asMap().entries.map((entry) {
            final index = entry.key;
            final place = entry.value;
            return ItineraryTile(
              place: place,
              index: index + 1,
              slotColor: _color,
              isEditing: isEditing,
              onRemove: onRemove != null ? () => onRemove!(place) : null,
              onTap: onPlaceTap != null ? () => onPlaceTap!(place) : null,
            );
          }),
        const Divider(height: 1),
      ],
    );
  }
}
