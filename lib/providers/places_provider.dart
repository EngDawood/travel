// lib/providers/places_provider.dart
import 'package:flutter/foundation.dart';

import '../models/place.dart';
import '../services/api_service.dart';
import '../services/database_helper.dart';
import '../config/constants.dart';

class PlacesProvider extends ChangeNotifier {
  List<Place> _fetchedPlaces = [];
  List<Place> _selectedPlaces = [];
  bool _isLoading = false;
  String? _error;

  // Current city context
  String _currentCity = '';
  double _cityLat = 0;
  double _cityLng = 0;

  List<Place> get fetchedPlaces => _fetchedPlaces;
  List<Place> get selectedPlaces => _selectedPlaces;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get currentCity => _currentCity;
  bool get canGenerateItinerary => _selectedPlaces.length >= 3;

  late final ApiService _api;
  final DatabaseHelper _db = DatabaseHelper.instance;

  PlacesProvider([ApiService? apiService])
      : _api = apiService ?? ApiService(apiKey: googleApiKey);

  /// Set the current city context.
  void setCity(String city, double lat, double lng) {
    _currentCity = city;
    _cityLat = lat;
    _cityLng = lng;
    _fetchedPlaces = [];
    _selectedPlaces = [];
    notifyListeners();
  }

  /// Fetch places for selected categories near the current city.
  Future<void> fetchPlaces(List<PlaceCategory> categories) async {
    _setLoading(true);
    _error = null;
    try {
      final places = await _api.searchNearbyMultiple(
        lat: _cityLat,
        lng: _cityLng,
        categories: categories,
      );
      // Cache to SQLite
      await _db.upsertPlaces(places);
      _fetchedPlaces = places;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to fetch places. Please try again.';
    } finally {
      _setLoading(false);
    }
  }

  /// Toggle selection of a place (add/remove from selected list).
  void toggleSelect(Place place) {
    final idx = _selectedPlaces.indexWhere((p) => p.placeId == place.placeId);
    if (idx >= 0) {
      _selectedPlaces.removeAt(idx);
    } else {
      _selectedPlaces.add(place);
    }
    notifyListeners();
  }

  /// Check if a place is currently selected.
  bool isSelected(Place place) =>
      _selectedPlaces.any((p) => p.placeId == place.placeId);

  /// Clear all selections and fetched places.
  void clearSelection() {
    _selectedPlaces = [];
    notifyListeners();
  }

  /// Clear everything (e.g. on city change).
  void reset() {
    _fetchedPlaces = [];
    _selectedPlaces = [];
    _currentCity = '';
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
