// lib/screens/places_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/places_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/itinerary_provider.dart';
import '../widgets/place_card.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final placesProvider = context.watch<PlacesProvider>();
    final places = placesProvider.fetchedPlaces;
    final isLoading = placesProvider.isLoading;
    final error = placesProvider.error;
    final selectedCount = placesProvider.selectedPlaces.length;
    final canGenerate = placesProvider.canGenerateItinerary;
    final remaining = 3 - selectedCount;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.placesListTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: l10n.placesListViewMap,
            onPressed: () => context.go('/map'),
          ),
        ],
      ),
      body: _buildBody(context, l10n, isLoading, error, places),
      bottomNavigationBar: places.isNotEmpty
          ? SafeArea(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.1),
                      blurRadius: 8,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        remaining > 0
                            ? l10n.placesListSelectMore(remaining)
                            : l10n.placesListSelectedCount(selectedCount),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    if (canGenerate)
                      ElevatedButton(
                        onPressed: () => _onGenerate(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.grey.shade900,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(l10n.placesListGenerate),
                      ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, AppLocalizations l10n, bool isLoading,
      String? error, List places) {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(l10n.placesListLoading),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 12),
              Text(error, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.go('/preferences'),
                child: Text(l10n.placesListGoBack),
              ),
            ],
          ),
        ),
      );
    }

    if (places.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            l10n.placesListEmpty,
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.placesListTitle,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.placesListSubtitle,
                style: TextStyle(fontSize: 13, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(top: 8, bottom: 16),
            itemCount: places.length,
            itemBuilder: (context, index) {
              final place = places[index];
              final placesProvider = context.watch<PlacesProvider>();
              return PlaceCard(
                place: place,
                isSelected: placesProvider.isSelected(place),
                onTap: () => context.go('/place/${place.placeId}'),
                onToggleSelect: () =>
                    context.read<PlacesProvider>().toggleSelect(place),
              );
            },
          ),
        ),
      ],
    );
  }

  void _onGenerate(BuildContext context) {
    final placesProvider = context.read<PlacesProvider>();
    final authProvider = context.read<AuthProvider>();
    final itineraryProvider = context.read<ItineraryProvider>();

    itineraryProvider.generateItinerary(
      selectedPlaces: placesProvider.selectedPlaces,
      city: placesProvider.currentCity,
      userId: authProvider.currentUser?.id ?? 0,
    );

    context.go('/itinerary');
  }
}
