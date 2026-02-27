// lib/screens/favorites_screen.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/place.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../services/preferences_service.dart';
import '../utils/helpers.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final PreferencesService _prefs = PreferencesService();
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<Place> _places = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    setState(() => _isLoading = true);
    final ids = await _prefs.getFavoriteIds();
    final places = <Place>[];
    for (final id in ids) {
      final place = await _db.getPlace(id);
      if (place != null) places.add(place);
    }
    if (mounted) {
      setState(() {
        _places = places;
        _isLoading = false;
      });
    }
  }

  Future<void> _toggleFavorite(String placeId) async {
    await _prefs.toggleFavorite(placeId);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Favourites')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _places.isEmpty
              ? _buildEmpty()
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _places.length,
                    itemBuilder: (context, index) =>
                        _FavoriteTile(
                          place: _places[index],
                          onTap: () => context.push('/place/${_places[index].placeId}').then((_) => _load()),
                          onToggle: () => _toggleFavorite(_places[index].placeId),
                        ),
                  ),
                ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.favorite_border, size: 72, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'No favourites yet. Tap \u2665 on a place to save it.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

class _FavoriteTile extends StatelessWidget {
  final Place place;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const _FavoriteTile({
    required this.place,
    required this.onTap,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final api = context.read<ApiService>();
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: place.photoReference != null
            ? CachedNetworkImage(
                imageUrl:
                    api.getPhotoUrl(place.photoReference!, maxWidth: 80),
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                placeholder: (_, __) => _placeholder(),
                errorWidget: (_, __, ___) => _placeholder(),
              )
            : _placeholder(),
      ),
      title: Text(
        place.name,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${capitalize(place.category)} · ${place.rating.toStringAsFixed(1)} ★',
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
      ),
      trailing: IconButton(
        icon: const Icon(Icons.favorite, color: Colors.red),
        onPressed: onToggle,
      ),
      onTap: onTap,
    );
  }

  Widget _placeholder() {
    return Container(
      width: 64,
      height: 64,
      color: Colors.grey[200],
      child: const Icon(Icons.image, color: Colors.grey),
    );
  }
}
