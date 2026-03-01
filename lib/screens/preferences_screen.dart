// lib/screens/preferences_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/constants.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/places_provider.dart';
import '../widgets/preference_category_card.dart';

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
    final l10n = AppLocalizations.of(context);
    if (_selected.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.preferencesSelectAtLeastOne)),
      );
      return;
    }
    context.read<PlacesProvider>().fetchPlaces(_selected.toList());
    context.go('/places');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final city = context.watch<PlacesProvider>().currentCity;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.preferencesTitle)),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.preferencesTitle,
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.preferencesSubtitle(city),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                itemCount: PlaceCategory.values.length,
                separatorBuilder: (_, __) => const SizedBox(height: 12),
                itemBuilder: (context, index) {
                  final category = PlaceCategory.values[index];
                  return PreferenceCategoryCard(
                    category: category,
                    isSelected: _selected.contains(category),
                    onTap: () => _toggle(category),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _selected.isEmpty ? null : _onGenerate,
                icon: const Icon(Icons.explore),
                label: Text(l10n.preferencesFindPlaces),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
