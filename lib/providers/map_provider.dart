// lib/providers/map_provider.dart
import 'package:flutter/foundation.dart';

import '../models/place.dart';

class MapProvider extends ChangeNotifier {
  Place? _selectedPlace;

  // Lat/lng stored as plain doubles — no google_maps_flutter dependency.
  double? _cameraLat;
  double? _cameraLng;

  Place? get selectedPlace => _selectedPlace;
  double? get cameraLat => _cameraLat;
  double? get cameraLng => _cameraLng;

  /// Called when places are loaded — sets initial camera target.
  void setPlaces(List<Place> places) {
    if (places.isNotEmpty) {
      _cameraLat = places.first.latitude;
      _cameraLng = places.first.longitude;
    }
    notifyListeners();
  }

  /// Select a place (e.g. from card or marker tap).
  void selectPlace(Place place) {
    _selectedPlace = place;
    _cameraLat = place.latitude;
    _cameraLng = place.longitude;
    notifyListeners();
  }

  void clearSelection() {
    _selectedPlace = null;
    notifyListeners();
  }

  void reset() {
    _selectedPlace = null;
    _cameraLat = null;
    _cameraLng = null;
    notifyListeners();
  }
}
