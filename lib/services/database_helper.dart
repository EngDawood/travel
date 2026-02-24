// lib/services/database_helper.dart
//
// Platform-aware entry point.
// Delegates to _InMemoryDb on web, _SqliteDb on mobile.

import 'package:flutter/foundation.dart' show kIsWeb;

import '../models/user.dart';
import '../models/place.dart';
import '../models/itinerary.dart';
import '../models/itinerary_place.dart';
import 'db/db_interface.dart';
import 'db/db_memory.dart';
import 'db/db_sqlite.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._();
  late final DbInterface _impl;

  DatabaseHelper._() {
    _impl = kIsWeb ? InMemoryDb() : SqliteDb();
  }

  // ── Users ──────────────────────────────────────────────────────────────────
  Future<int> insertUser(User user) => _impl.insertUser(user);
  Future<User?> getUserByEmail(String email) => _impl.getUserByEmail(email);
  Future<User?> getUserById(int id) => _impl.getUserById(id);
  Future<int> updateUserCategories(int userId, List<String> categories) =>
      _impl.updateUserCategories(userId, categories);
  Future<int> updateUser(User user) => _impl.updateUser(user);
  Future<int> deleteUser(int id) => _impl.deleteUser(id);

  // ── Places ─────────────────────────────────────────────────────────────────
  Future<void> upsertPlace(Place place) => _impl.upsertPlace(place);
  Future<void> upsertPlaces(List<Place> places) => _impl.upsertPlaces(places);
  Future<Place?> getPlace(String placeId) => _impl.getPlace(placeId);
  Future<List<Place>> getPlacesByCategory(String category) =>
      _impl.getPlacesByCategory(category);
  Future<int> deletePlace(String placeId) => _impl.deletePlace(placeId);

  // ── Itineraries ────────────────────────────────────────────────────────────
  Future<int> insertItinerary(Itinerary itinerary) =>
      _impl.insertItinerary(itinerary);
  Future<List<Itinerary>> getItinerariesForUser(int userId) =>
      _impl.getItinerariesForUser(userId);
  Future<Itinerary?> getItinerary(int id) => _impl.getItinerary(id);
  Future<int> updateItineraryName(int id, String name) =>
      _impl.updateItineraryName(id, name);
  Future<int> deleteItinerary(int id) => _impl.deleteItinerary(id);
  Future<void> replaceItineraryPlaces(
          int itineraryId, List<ItineraryPlace> places) =>
      _impl.replaceItineraryPlaces(itineraryId, places);
}
