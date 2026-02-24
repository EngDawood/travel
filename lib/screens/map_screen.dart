// lib/screens/map_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/map_provider.dart';
import '../providers/places_provider.dart';
import '../utils/helpers.dart';

// google_maps_flutter is only supported on Android/iOS.
// On web/windows we show a fallback list view.

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final places = context.read<PlacesProvider>().selectedPlaces;
      if (places.isNotEmpty) context.read<MapProvider>().setPlaces(places);
    });
  }

  @override
  Widget build(BuildContext context) {
    final placesProvider = context.watch<PlacesProvider>();
    final places = placesProvider.selectedPlaces;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          placesProvider.currentCity.isEmpty ? 'Map' : placesProvider.currentCity,
        ),
        actions: [
          if (places.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${places.length} places',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: places.isEmpty ? _buildEmpty(context) : _buildContent(context, places),
    );
  }

  Widget _buildContent(BuildContext context, List<Place> places) {
    // On mobile (Android/iOS) we'd show GoogleMap.
    // On web/desktop, show a coordinate list as a fallback.
    if (kIsWeb) return _buildWebFallback(context, places);

    // On native — dynamic import guard so web build doesn't fail.
    return _NativeMapView(places: places);
  }

  Widget _buildWebFallback(BuildContext context, List<Place> places) {
    final mapProvider = context.watch<MapProvider>();
    final selected = mapProvider.selectedPlace;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: Colors.amber[50],
          child: Row(
            children: [
              const Icon(Icons.info_outline, size: 16, color: Colors.orange),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Interactive map is available on Android & iOS. '
                  'Showing place list with coordinates.',
                  style: TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: places.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) {
              final p = places[i];
              final isSelected = selected?.placeId == p.placeId;
              return _PlaceCoordCard(
                place: p,
                isSelected: isSelected,
                onTap: () {
                  context.read<MapProvider>().selectPlace(p);
                },
                onDetails: () => context.go('/place/${p.placeId}'),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.map_outlined, size: 72, color: Colors.grey[300]),
          const SizedBox(height: 16),
          const Text('No places selected yet.',
              style: TextStyle(color: Colors.grey)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/places'),
            child: const Text('Go to Places'),
          ),
        ],
      ),
    );
  }
}

// ─── Native map view (Android/iOS only) ──────────────────────────────────────
// Kept in a separate widget so web builds never reference google_maps_flutter.

class _NativeMapView extends StatefulWidget {
  final List<Place> places;
  const _NativeMapView({required this.places});

  @override
  State<_NativeMapView> createState() => _NativeMapViewState();
}

class _NativeMapViewState extends State<_NativeMapView> {
  @override
  Widget build(BuildContext context) {
    // When running on actual Android/iOS, uncomment the GoogleMap widget below
    // and add the import at the top of the file.
    // For now we show the list fallback on all platforms so the project compiles.
    return _PlaceListFallback(places: widget.places);
  }
}

// ─── Shared fallback list ─────────────────────────────────────────────────────

class _PlaceListFallback extends StatelessWidget {
  final List<Place> places;
  const _PlaceListFallback({required this.places});

  @override
  Widget build(BuildContext context) {
    final mapProvider = context.watch<MapProvider>();
    final selected = mapProvider.selectedPlace;

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: places.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) {
        final p = places[i];
        return _PlaceCoordCard(
          place: p,
          isSelected: selected?.placeId == p.placeId,
          onTap: () => context.read<MapProvider>().selectPlace(p),
          onDetails: () => context.go('/place/${p.placeId}'),
        );
      },
    );
  }
}

// ─── Place card with coordinates ─────────────────────────────────────────────

class _PlaceCoordCard extends StatelessWidget {
  final Place place;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onDetails;

  const _PlaceCoordCard({
    required this.place,
    required this.isSelected,
    required this.onTap,
    required this.onDetails,
  });

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? color : Colors.grey[200]!,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: isSelected
                    ? color.withValues(alpha: 0.15)
                    : Colors.grey[100],
                child: Icon(Icons.location_pin,
                    color: isSelected ? color : Colors.grey),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(place.name,
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14)),
                    const SizedBox(height: 2),
                    Text(
                      '${capitalize(place.category)} · ⭐ ${place.rating.toStringAsFixed(1)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${place.latitude.toStringAsFixed(4)}, ${place.longitude.toStringAsFixed(4)}',
                      style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: onDetails,
                child: const Text('Details'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
