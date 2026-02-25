// lib/providers/itinerary_provider.dart
import 'package:flutter/foundation.dart';

import '../models/itinerary.dart';
import '../models/place.dart';
import '../services/database_helper.dart';
import '../utils/app_logger.dart';
import '../utils/itinerary_generator.dart';

class ItineraryProvider extends ChangeNotifier {
  Itinerary? _currentItinerary;
  List<Itinerary> _savedItineraries = [];
  bool _isLoading = false;
  String? _error;

  Itinerary? get currentItinerary => _currentItinerary;
  List<Itinerary> get savedItineraries => _savedItineraries;
  bool get isLoading => _isLoading;
  String? get error => _error;

  final DatabaseHelper _db = DatabaseHelper.instance;

  /// Generate an itinerary from selected places.
  /// Does NOT save to DB yet — call [saveItinerary] for that.
  void generateItinerary({
    required List<Place> selectedPlaces,
    required String city,
    required int userId,
  }) {
    _error = null;
    try {
      AppLogger.info('[Itinerary] Generating for $city with ${selectedPlaces.length} places');
      final slotMap = ItineraryGenerator.generate(selectedPlaces);
      _currentItinerary = ItineraryGenerator.buildItinerary(
        slotMap: slotMap,
        city: city,
        userId: userId,
      );
      AppLogger.info('[Itinerary] Generated: ${_currentItinerary?.places.length ?? 0} slots');
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('[Itinerary] Generation failed', error: e, stack: stack);
      _error = 'Failed to generate itinerary. Please try again.';
      notifyListeners();
    }
  }

  /// Save the current itinerary with a user-given [name].
  Future<bool> saveItinerary(String name) async {
    if (_currentItinerary == null) return false;
    _setLoading(true);
    _error = null;
    try {
      final toSave = _currentItinerary!.copyWith(name: name);
      final id = await _db.insertItinerary(toSave);
      _currentItinerary = toSave.copyWith(id: id);
      notifyListeners();
      return true;
    } catch (e, stack) {
      AppLogger.error('[Itinerary] Failed to save', error: e, stack: stack);
      _error = 'Local storage error. Try restarting the app.';
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Load all saved itineraries for [userId].
  Future<void> loadSaved(int userId) async {
    _setLoading(true);
    _error = null;
    try {
      _savedItineraries = await _db.getItinerariesForUser(userId);
    } catch (e, stack) {
      AppLogger.error('[Itinerary] Failed to load saved', error: e, stack: stack);
      _error = 'Local storage error. Try restarting the app.';
    } finally {
      _setLoading(false);
    }
  }

  /// Delete an itinerary by [id].
  Future<void> deleteItinerary(int id) async {
    try {
      await _db.deleteItinerary(id);
      _savedItineraries.removeWhere((it) => it.id == id);
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('[Itinerary] Failed to delete id=$id', error: e, stack: stack);
      _error = 'Local storage error. Try restarting the app.';
      notifyListeners();
    }
  }

  /// Rename a saved itinerary.
  Future<void> renameItinerary(int id, String name) async {
    try {
      await _db.updateItineraryName(id, name);
      final idx = _savedItineraries.indexWhere((it) => it.id == id);
      if (idx >= 0) {
        _savedItineraries[idx] = _savedItineraries[idx].copyWith(name: name);
        notifyListeners();
      }
    } catch (e, stack) {
      AppLogger.error('[Itinerary] Failed to rename id=$id', error: e, stack: stack);
      _error = 'Local storage error. Try restarting the app.';
      notifyListeners();
    }
  }

  /// Set a saved itinerary as the current one (for viewing).
  void viewItinerary(Itinerary itinerary) {
    _currentItinerary = itinerary;
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
