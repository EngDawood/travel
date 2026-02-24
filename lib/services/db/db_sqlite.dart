// lib/services/db/db_sqlite.dart
// SQLite database — used on Android & iOS via sqflite.

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../../models/user.dart';
import '../../models/place.dart';
import '../../models/itinerary.dart';
import '../../models/itinerary_place.dart';
import 'db_interface.dart';

class SqliteDb implements DbInterface {
  static Database? _db;

  Future<Database> get _database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'travel.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL UNIQUE,
        password TEXT NOT NULL,
        preferred_categories TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE places (
        place_id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        rating REAL DEFAULT 0,
        price_level INTEGER DEFAULT 0,
        address TEXT,
        latitude REAL NOT NULL,
        longitude REAL NOT NULL,
        description TEXT,
        photo_reference TEXT,
        open_now INTEGER
      )
    ''');
    await db.execute('''
      CREATE TABLE itineraries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        city TEXT NOT NULL,
        name TEXT,
        date TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
      )
    ''');
    await db.execute('''
      CREATE TABLE itinerary_places (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        itinerary_id INTEGER NOT NULL,
        place_id TEXT NOT NULL,
        time_slot TEXT NOT NULL CHECK(time_slot IN ('morning','afternoon','evening')),
        order_index INTEGER NOT NULL,
        FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
        FOREIGN KEY (place_id) REFERENCES places(place_id)
      )
    ''');
  }

  // ── Users ──────────────────────────────────────────────────────────────────

  @override
  Future<int> insertUser(User user) async {
    final db = await _database;
    return db.insert('users', user.toDb(),
        conflictAlgorithm: ConflictAlgorithm.abort);
  }

  @override
  Future<User?> getUserByEmail(String email) async {
    final db = await _database;
    final maps = await db
        .query('users', where: 'email = ?', whereArgs: [email], limit: 1);
    if (maps.isEmpty) return null;
    return User.fromDb(maps.first);
  }

  @override
  Future<User?> getUserById(int id) async {
    final db = await _database;
    final maps = await db
        .query('users', where: 'id = ?', whereArgs: [id], limit: 1);
    if (maps.isEmpty) return null;
    return User.fromDb(maps.first);
  }

  @override
  Future<int> updateUserCategories(
      int userId, List<String> categories) async {
    final user = await getUserById(userId);
    if (user == null) return 0;
    final db = await _database;
    return db.update(
      'users',
      user.copyWith(preferredCategories: categories).toDb(),
      where: 'id = ?',
      whereArgs: [userId],
    );
  }

  @override
  Future<int> updateUser(User user) async {
    final db = await _database;
    return db.update('users', user.toDb(),
        where: 'id = ?', whereArgs: [user.id]);
  }

  @override
  Future<int> deleteUser(int id) async {
    final db = await _database;
    return db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // ── Places ─────────────────────────────────────────────────────────────────

  @override
  Future<void> upsertPlace(Place place) async {
    final db = await _database;
    await db.insert('places', place.toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> upsertPlaces(List<Place> places) async {
    final db = await _database;
    final batch = db.batch();
    for (final p in places) {
      batch.insert('places', p.toDb(),
          conflictAlgorithm: ConflictAlgorithm.replace);
    }
    await batch.commit(noResult: true);
  }

  @override
  Future<Place?> getPlace(String placeId) async {
    final db = await _database;
    final maps = await db.query('places',
        where: 'place_id = ?', whereArgs: [placeId], limit: 1);
    if (maps.isEmpty) return null;
    return Place.fromDb(maps.first);
  }

  @override
  Future<List<Place>> getPlacesByCategory(String category) async {
    final db = await _database;
    final maps = await db
        .query('places', where: 'category = ?', whereArgs: [category]);
    return maps.map(Place.fromDb).toList();
  }

  @override
  Future<int> deletePlace(String placeId) async {
    final db = await _database;
    return db.delete('places', where: 'place_id = ?', whereArgs: [placeId]);
  }

  // ── Itineraries ────────────────────────────────────────────────────────────

  @override
  Future<int> insertItinerary(Itinerary itinerary) async {
    final db = await _database;
    final id = await db.insert('itineraries', itinerary.toDb());
    if (itinerary.places.isNotEmpty) {
      final batch = db.batch();
      for (final ip in itinerary.places) {
        batch.insert(
          'itinerary_places',
          ip.copyWith(itineraryId: id).toDb(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    }
    return id;
  }

  @override
  Future<List<Itinerary>> getItinerariesForUser(int userId) async {
    final db = await _database;
    final rows = await db.query('itineraries',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC');
    final List<Itinerary> result = [];
    for (final row in rows) {
      final id = row['id'] as int;
      final places = await _getItineraryPlaces(id);
      result.add(Itinerary.fromDb(row, places: places));
    }
    return result;
  }

  @override
  Future<Itinerary?> getItinerary(int id) async {
    final db = await _database;
    final rows = await db
        .query('itineraries', where: 'id = ?', whereArgs: [id], limit: 1);
    if (rows.isEmpty) return null;
    final places = await _getItineraryPlaces(id);
    return Itinerary.fromDb(rows.first, places: places);
  }

  Future<List<ItineraryPlace>> _getItineraryPlaces(int itineraryId) async {
    final db = await _database;
    final rows = await db.query('itinerary_places',
        where: 'itinerary_id = ?',
        whereArgs: [itineraryId],
        orderBy: 'time_slot, order_index');
    return rows.map(ItineraryPlace.fromDb).toList();
  }

  @override
  Future<int> updateItineraryName(int id, String name) async {
    final db = await _database;
    return db.update('itineraries', {'name': name},
        where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> deleteItinerary(int id) async {
    final db = await _database;
    return db.delete('itineraries', where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<void> replaceItineraryPlaces(
      int itineraryId, List<ItineraryPlace> places) async {
    final db = await _database;
    final batch = db.batch();
    batch.delete('itinerary_places',
        where: 'itinerary_id = ?', whereArgs: [itineraryId]);
    for (final ip in places) {
      batch.insert(
        'itinerary_places',
        ip.copyWith(itineraryId: itineraryId).toDb(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
