// lib/screens/places_list_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/places_provider.dart';
import '../providers/auth_provider.dart';
import '../providers/itinerary_provider.dart';
import '../widgets/place_card.dart';

class PlacesListScreen extends StatelessWidget {
  const PlacesListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final placesProvider = context.watch<PlacesProvider>();
    final places = placesProvider.fetchedPlaces;
    final isLoading = placesProvider.isLoading;
    final error = placesProvider.error;
    final selectedCount = placesProvider.selectedPlaces.length;
    final canGenerate = placesProvider.canGenerateItinerary;
    final remaining = 3 - selectedCount;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Places'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: 'View on Map',
            onPressed: () => context.go('/map'),
          ),
        ],
      ),
      body: _buildBody(context, isLoading, error, places),
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
                            ? 'Select $remaining more place${remaining == 1 ? '' : 's'}'
                            : '$selectedCount places selected',
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
                        child: const Text('Generate'),
                      ),
                  ],
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(BuildContext context, bool isLoading, String? error,
      List places) {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Finding great places...'),
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
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (places.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No places found. Try different categories or a broader area.',
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
                'Select Places',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Choose at least 3 places to visit.',
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
