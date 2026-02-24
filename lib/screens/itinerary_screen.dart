// lib/screens/itinerary_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/itinerary_provider.dart';
import '../providers/places_provider.dart';
import '../services/database_helper.dart';
import '../utils/helpers.dart';
import '../widgets/time_slot_section.dart';

class ItineraryScreen extends StatefulWidget {
  const ItineraryScreen({super.key});

  @override
  State<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends State<ItineraryScreen> {
  bool _isEditing = false;

  // Local slot map built from itinerary + fetched places
  Map<String, List<Place>> _slotMap = {
    'morning': [],
    'afternoon': [],
    'evening': [],
  };

  bool _built = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_built) {
      _buildSlotMap();
      _built = true;
    }
  }

  Future<void> _buildSlotMap() async {
    final itinerary =
        context.read<ItineraryProvider>().currentItinerary;
    if (itinerary == null) return;

    final fetchedPlaces = context.read<PlacesProvider>().fetchedPlaces;
    final selectedPlaces = context.read<PlacesProvider>().selectedPlaces;
    final allPlaces = {...fetchedPlaces, ...selectedPlaces}
        .toSet()
        .toList();

    // Also pull from DB in case some places are only in cache
    final Map<String, Place> placeMap = {
      for (final p in allPlaces) p.placeId: p,
    };

    for (final ip in itinerary.places) {
      if (!placeMap.containsKey(ip.placeId)) {
        final cached = await DatabaseHelper.instance.getPlace(ip.placeId);
        if (cached != null) placeMap[cached.placeId] = cached;
      }
    }

    final map = <String, List<Place>>{
      'morning': [],
      'afternoon': [],
      'evening': [],
    };

    final sorted = [...itinerary.places]
      ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

    for (final ip in sorted) {
      final place = placeMap[ip.placeId];
      if (place != null && map.containsKey(ip.timeSlot)) {
        map[ip.timeSlot]!.add(place);
      }
    }

    if (mounted) setState(() => _slotMap = map);
  }

  void _removePlace(Place place) {
    setState(() {
      for (final slot in _slotMap.keys) {
        _slotMap[slot]!.removeWhere((p) => p.placeId == place.placeId);
      }
    });
  }

  Future<void> _onSave() async {
    final nameController = TextEditingController();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Save Itinerary'),
        content: TextField(
          controller: nameController,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Give your plan a name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed != true || !mounted) return;

    final name = nameController.text.trim().isEmpty
        ? 'Trip to ${context.read<ItineraryProvider>().currentItinerary?.city ?? 'Unknown'}'
        : nameController.text.trim();

    final success = await context.read<ItineraryProvider>().saveItinerary(name);
    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Itinerary saved!')),
      );
      context.go('/saved');
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to save. Try again.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final itinerary = context.watch<ItineraryProvider>().currentItinerary;
    final totalPlaces =
        _slotMap.values.fold(0, (sum, list) => sum + list.length);

    return Scaffold(
      appBar: AppBar(
        title: Text(itinerary?.city ?? 'Your Itinerary'),
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Done' : 'Edit',
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
      body: itinerary == null
          ? const Center(child: Text('No itinerary generated yet.'))
          : Column(
              children: [
                // Summary banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 10),
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.08),
                  child: Text(
                    '${formatDate(itinerary.date)} · $totalPlaces places',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(
                  child: ListView(
                    children: [
                      TimeSlotSection(
                        slot: 'morning',
                        places: _slotMap['morning']!,
                        isEditing: _isEditing,
                        onRemove: _isEditing ? _removePlace : null,
                      ),
                      TimeSlotSection(
                        slot: 'afternoon',
                        places: _slotMap['afternoon']!,
                        isEditing: _isEditing,
                        onRemove: _isEditing ? _removePlace : null,
                      ),
                      TimeSlotSection(
                        slot: 'evening',
                        places: _slotMap['evening']!,
                        isEditing: _isEditing,
                        onRemove: _isEditing ? _removePlace : null,
                      ),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ],
            ),
      bottomNavigationBar: itinerary == null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ElevatedButton.icon(
                  onPressed: _onSave,
                  icon: const Icon(Icons.save),
                  label: const Text('Save Itinerary'),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 48),
                  ),
                ),
              ),
            ),
    );
  }
}
