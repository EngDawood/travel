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
    final city = placesProvider.currentCity;
    final selectedCount = placesProvider.selectedPlaces.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(city.isEmpty ? 'Places' : city),
        actions: [
          if (selectedCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '$selectedCount selected',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(context, isLoading, error, places),
      floatingActionButton: placesProvider.canGenerateItinerary
          ? FloatingActionButton.extended(
              onPressed: () => _onGenerate(context),
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Generate Itinerary'),
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
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            'Tap a card to view details. Tap + to add to your itinerary. Select at least 3 to generate.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
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
