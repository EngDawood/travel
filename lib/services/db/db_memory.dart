// lib/services/db/db_memory.dart
// In-memory database — used on Web where sqflite is unavailable.
// Data is lost on page reload.

import '../../models/user.dart';
import '../../models/place.dart';
import '../../models/itinerary.dart';
import '../../models/itinerary_place.dart';
import 'db_interface.dart';
import '../../utils/app_logger.dart';

class InMemoryDb implements DbInterface {
  final Map<int, User> _users = {};
  final Map<String, Place> _places = {};
  final Map<int, Itinerary> _itineraries = {};
  final Map<int, List<ItineraryPlace>> _itineraryPlaces = {};

  int _nextUserId = 1;
  int _nextItineraryId = 1;
  int _nextIpId = 1;

  // ── Users ──────────────────────────────────────────────────────────────────

  @override
  Future<int> insertUser(User user) async {
    if (_users.values.any((u) => u.email == user.email)) {
      throw Exception('Email already exists');
    }
    final id = _nextUserId++;
    _users[id] = user.copyWith(id: id);
    AppLogger.info('[DB] InMemoryDb: inserted user id=$id email=${user.email}');
    return id;
  }

  @override
  Future<User?> getUserByEmail(String email) async =>
      _users.values.where((u) => u.email == email).firstOrNull;

  @override
  Future<User?> getUserById(int id) async => _users[id];

  @override
  Future<int> updateUserCategories(
      int userId, List<String> categories) async {
    final user = _users[userId];
    if (user == null) return 0;
    _users[userId] = user.copyWith(preferredCategories: categories);
    return 1;
  }

  @override
  Future<int> updateUser(User user) async {
    if (user.id == null || !_users.containsKey(user.id)) return 0;
    _users[user.id!] = user;
    return 1;
  }

  @override
  Future<int> deleteUser(int id) async =>
      _users.remove(id) != null ? 1 : 0;

  // ── Places ─────────────────────────────────────────────────────────────────

  @override
  Future<void> upsertPlace(Place place) async =>
      _places[place.placeId] = place;

  @override
  Future<void> upsertPlaces(List<Place> places) async {
    for (final p in places) {
      _places[p.placeId] = p;
    }
  }

  @override
  Future<Place?> getPlace(String placeId) async => _places[placeId];

  @override
  Future<List<Place>> getPlacesByCategory(String category) async =>
      _places.values.where((p) => p.category == category).toList();

  @override
  Future<int> deletePlace(String placeId) async =>
      _places.remove(placeId) != null ? 1 : 0;

  // ── Itineraries ────────────────────────────────────────────────────────────

  @override
  Future<int> insertItinerary(Itinerary itinerary) async {
    final id = _nextItineraryId++;
    _itineraries[id] = itinerary.copyWith(id: id);
    _itineraryPlaces[id] = itinerary.places
        .map((ip) =>
            ip.copyWith(id: _nextIpId++, itineraryId: id))
        .toList();
    AppLogger.info('[DB] InMemoryDb: inserted itinerary id=$id city=${itinerary.city}');
    return id;
  }

  @override
  Future<List<Itinerary>> getItinerariesForUser(int userId) async {
    final list = _itineraries.values
        .where((it) => it.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return list.map((it) {
      return it.copyWith(places: _itineraryPlaces[it.id] ?? []);
    }).toList();
  }

  @override
  Future<Itinerary?> getItinerary(int id) async {
    final it = _itineraries[id];
    if (it == null) return null;
    return it.copyWith(places: _itineraryPlaces[id] ?? []);
  }

  @override
  Future<int> updateItineraryName(int id, String name) async {
    final it = _itineraries[id];
    if (it == null) return 0;
    _itineraries[id] = it.copyWith(name: name);
    return 1;
  }

  @override
  Future<int> deleteItinerary(int id) async {
    _itineraryPlaces.remove(id);
    return _itineraries.remove(id) != null ? 1 : 0;
  }

  @override
  Future<void> replaceItineraryPlaces(
      int itineraryId, List<ItineraryPlace> places) async {
    _itineraryPlaces[itineraryId] = places
        .map((ip) =>
            ip.copyWith(id: _nextIpId++, itineraryId: itineraryId))
        .toList();
  }
}
