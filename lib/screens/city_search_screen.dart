// lib/screens/city_search_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../config/popular_destinations.dart';
import '../l10n/generated/app_localizations.dart';
import '../providers/places_provider.dart';
import '../services/api_service.dart';
import '../widgets/destination_card.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late ApiService _api;
  bool _apiInitialized = false;

  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PlacesProvider>().loadRecentSearches();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_apiInitialized) {
      _api = context.read<ApiService>();
      _apiInitialized = true;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _onSearchChanged(String input) async {
    if (input.trim().length < 2) {
      setState(() => _suggestions = []);
      return;
    }
    setState(() {
      _isSearching = true;
      _error = null;
    });
    final l10n = AppLocalizations.of(context);
    try {
      final results = await _api.autocompleteCity(input);
      if (!mounted) return;
      setState(() => _suggestions = results);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.citySearchFailed);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _onCitySelected(Map<String, dynamic> suggestion) async {
    final description = suggestion['description'] as String;
    final placeId = suggestion['place_id'] as String;
    final l10n = AppLocalizations.of(context);

    setState(() {
      _isSearching = true;
      _suggestions = [];
      _controller.text = description;
      _error = null;
    });

    try {
      final latLng = await _api.getCityLatLng(placeId);
      if (!mounted) return;
      context.read<PlacesProvider>().setCity(
            description,
            latLng['lat']!,
            latLng['lng']!,
            placeId: placeId,
          );
      context.go('/preferences');
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = l10n.citySearchCityFailed);
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  void _onRecentSearchTap(Map<String, String> search) {
    final description = search['description'];
    final placeId = search['place_id'];
    if (description == null || placeId == null) return;
    _onCitySelected({'description': description, 'place_id': placeId});
  }

  void _onPopularDestinationTap(PopularDestination dest) {
    if (!mounted) return;
    context.read<PlacesProvider>().setCity(
          '${dest.city}, ${dest.country}',
          dest.lat,
          dest.lng,
        );
    context.go('/preferences');
  }

  @override
  Widget build(BuildContext context) {
    final recentSearches = context.watch<PlacesProvider>().recentSearches;

    return Scaffold(
      body: SafeArea(
        child: _suggestions.isNotEmpty || _isSearching
            ? _buildSearchResults()
            : _buildHomeContent(recentSearches),
      ),
    );
  }

  Widget _buildHomeContent(List<Map<String, String>> recentSearches) {
    final l10n = AppLocalizations.of(context);
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
      children: [
        // Header
        Text(
          l10n.citySearchTitle,
          style: Theme.of(context)
              .textTheme
              .headlineMedium
              ?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.citySearchSubtitle,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),

        // Search bar
        _buildSearchBar(l10n),

        if (_error != null) ...[
          const SizedBox(height: 8),
          Text(_error!, style: const TextStyle(color: Colors.red)),
        ],

        // Recent searches
        if (recentSearches.isNotEmpty) ...[
          const SizedBox(height: 28),
          Row(
            children: [
              Icon(Icons.history, size: 16, color: Colors.grey[600]),
              const SizedBox(width: 6),
              Text(
                l10n.citySearchRecentSearches,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[600],
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: recentSearches.map((search) {
              return ActionChip(
                label: Text(search['description'] ?? ''),
                onPressed: () => _onRecentSearchTap(search),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],

        // Popular destinations
        const SizedBox(height: 28),
        Row(
          children: [
            Icon(Icons.trending_up, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 6),
            Text(
              l10n.citySearchPopularDestinations,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
                letterSpacing: 0.8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.3,
          ),
          itemCount: popularDestinations.length,
          itemBuilder: (context, index) {
            final dest = popularDestinations[index];
            return DestinationCard(
              city: dest.city,
              country: dest.country,
              imageUrl: dest.imageUrl,
              onTap: () => _onPopularDestinationTap(dest),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.citySearchTitle,
            style: Theme.of(context)
                .textTheme
                .headlineMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.citySearchSubtitle,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          _buildSearchBar(l10n),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(_error!, style: const TextStyle(color: Colors.red)),
          ],
          if (_isSearching)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CircularProgressIndicator()),
            ),
          if (_suggestions.isNotEmpty)
            Expanded(
              child: ListView.separated(
                itemCount: _suggestions.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final s = _suggestions[index];
                  return ListTile(
                    leading: const Icon(Icons.location_city),
                    title: Text(s['description'] as String),
                    onTap: () => _onCitySelected(s),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations l10n) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: l10n.citySearchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _controller.clear();
                  setState(() => _suggestions = []);
                },
              )
            : null,
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
      ),
      onChanged: _onSearchChanged,
    );
  }
}
