// lib/screens/city_search_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../providers/places_provider.dart';
import '../services/api_service.dart';

class CitySearchScreen extends StatefulWidget {
  const CitySearchScreen({super.key});

  @override
  State<CitySearchScreen> createState() => _CitySearchScreenState();
}

class _CitySearchScreenState extends State<CitySearchScreen> {
  final TextEditingController _controller = TextEditingController();
  late final ApiService _api;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _api = context.read<ApiService>();
  }

  List<Map<String, dynamic>> _suggestions = [];
  bool _isSearching = false;
  String? _error;

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
    try {
      final results = await _api.autocompleteCity(input);
      setState(() => _suggestions = results);
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Search failed. Check your connection.');
    } finally {
      setState(() => _isSearching = false);
    }
  }

  Future<void> _onCitySelected(Map<String, dynamic> suggestion) async {
    final description = suggestion['description'] as String;
    final placeId = suggestion['place_id'] as String;

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
          );
      context.go('/preferences');
    } on ApiException catch (e) {
      setState(() => _error = e.message);
    } catch (_) {
      setState(() => _error = 'Could not load city. Try again.');
    } finally {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search City')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Where do you want to travel?',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Enter a city name...',
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
              ),
              onChanged: _onSearchChanged,
            ),
            const SizedBox(height: 8),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_isSearching)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 12),
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
      ),
    );
  }
}
