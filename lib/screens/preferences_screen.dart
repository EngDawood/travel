// lib/screens/preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../providers/places_provider.dart';
import '../widgets/category_chip.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  final Set<PlaceCategory> _selected = {};

  void _toggle(PlaceCategory category) {
    setState(() {
      if (_selected.contains(category)) {
        _selected.remove(category);
      } else {
        _selected.add(category);
      }
    });
  }

  void _onGenerate() {
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one category.')),
      );
      return;
    }
    context.read<PlacesProvider>().fetchPlaces(_selected.toList());
    context.go('/places');
  }

  @override
  Widget build(BuildContext context) {
    final city = context.watch<PlacesProvider>().currentCity;

    return Scaffold(
      appBar: AppBar(title: const Text('What are you into?')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Planning a trip to $city',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Select the types of places you want to visit.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: PlaceCategory.values.map((category) {
                return CategoryChip(
                  category: category,
                  isSelected: _selected.contains(category),
                  onTap: () => _toggle(category),
                );
              }).toList(),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selected.isEmpty ? null : _onGenerate,
                icon: const Icon(Icons.explore),
                label: const Text('Find Places'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
