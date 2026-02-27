// lib/screens/place_detail_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../providers/places_provider.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart';
import '../utils/helpers.dart';

class PlaceDetailScreen extends StatefulWidget {
  final String placeId;
  const PlaceDetailScreen({super.key, required this.placeId});

  @override
  State<PlaceDetailScreen> createState() => _PlaceDetailScreenState();
}

class _PlaceDetailScreenState extends State<PlaceDetailScreen> {
  Place? _place;
  bool _isLoading = true;
  String? _error;
  bool _isFavorite = false;

  late ApiService _api;
  bool _apiInitialized = false;
  final DatabaseHelper _db = DatabaseHelper.instance;
  final PreferencesService _prefs = PreferencesService();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_apiInitialized) {
      _api = context.read<ApiService>();
      _apiInitialized = true;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadPlace());
  }

  Future<void> _loadPlace() async {
    if (widget.placeId.isEmpty) {
      setState(() {
        _error = 'Invalid place ID.';
        _isLoading = false;
      });
      return;
    }

    final favorited = await _prefs.isFavorite(widget.placeId);
    if (!mounted) return;

    // Try cache first
    final cached = await _db.getPlace(widget.placeId);
    if (!mounted) return;
    if (cached != null) {
      setState(() {
        _place = cached;
        _isFavorite = favorited;
        _isLoading = false;
      });
      return;
    }

    // Fallback to API
    try {
      final place = await _api.getPlaceDetails(widget.placeId, 'attraction');
      await _db.upsertPlace(place);
      if (!mounted) return;
      setState(() {
        _place = place;
        _isFavorite = favorited;
        _isLoading = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Failed to load place details.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : _buildContent(),
    );
  }

  Widget _buildError() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 12),
          Text(_error!),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.pop(),
            child: const Text('Go Back'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    final place = _place!;
    final api = context.read<ApiService>();
    final isSelected =
        context.watch<PlacesProvider>().isSelected(place);
    final color = Theme.of(context).colorScheme.primary;

    return CustomScrollView(
      slivers: [
        // Hero photo app bar
        SliverAppBar(
          expandedHeight: 240,
          pinned: true,
          actions: [
            IconButton(
              icon: Icon(
                _isFavorite ? Icons.favorite : Icons.favorite_border,
                color: _isFavorite ? Colors.red : Colors.white,
              ),
              onPressed: () async {
                final nowFavorited =
                    await _prefs.toggleFavorite(place.placeId);
                if (!mounted) return;
                setState(() => _isFavorite = nowFavorited);
              },
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: place.photoReference != null
                ? CachedNetworkImage(
                    imageUrl:
                        api.getPhotoUrl(place.photoReference!, maxWidth: 800),
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.grey[300]),
                    errorWidget: (_, __, ___) =>
                        Container(color: Colors.grey[300]),
                  )
                : Container(color: Colors.grey[300]),
          ),
        ),

        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + open status
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: Theme.of(context)
                            .textTheme
                            .headlineSmall
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ),
                    if (place.openNow != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color:
                              place.openNow! ? Colors.green[50] : Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: place.openNow! ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Text(
                          place.openNow! ? 'Open' : 'Closed',
                          style: TextStyle(
                            color: place.openNow! ? Colors.green : Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 8),

                // Rating + price
                Row(
                  children: [
                    RatingBarIndicator(
                      rating: place.rating,
                      itemBuilder: (_, __) =>
                          const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 18,
                    ),
                    const SizedBox(width: 8),
                    Text(place.rating.toStringAsFixed(1)),
                    const SizedBox(width: 16),
                    Text(
                      priceLevelToString(place.priceLevel),
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Address
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        place.address,
                        style: TextStyle(color: Colors.grey[700], fontSize: 13),
                      ),
                    ),
                  ],
                ),

                // Description
                if (place.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    'About',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    place.description!,
                    style: const TextStyle(height: 1.5),
                  ),
                ],

                const SizedBox(height: 28),

                // Action buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/map'),
                        icon: const Icon(Icons.map),
                        label: const Text('View on Map'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<PlacesProvider>().toggleSelect(place);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(isSelected
                                  ? 'Removed from itinerary'
                                  : 'Added to itinerary'),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: Icon(
                            isSelected ? Icons.check : Icons.add),
                        label: Text(
                            isSelected ? 'Added' : 'Add to Itinerary'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              isSelected ? Colors.green : color,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
