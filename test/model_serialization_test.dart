// test/model_serialization_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travel/models/user.dart';
import 'package:travel/models/place.dart';
import 'package:travel/models/itinerary.dart';
import 'package:travel/models/itinerary_place.dart';

void main() {
  // ─── User ────────────────────────────────────────────────────────────────

  group('User serialization', () {
    final user = User(
      id: 1,
      username: 'abdulrahman',
      email: 'test@example.com',
      password: 'hashed_pw',
      preferredCategories: ['cafe', 'attraction'],
    );

    test('toJson / fromJson round-trip', () {
      final json = user.toJson();
      final restored = User.fromJson(json);
      expect(restored.id, equals(user.id));
      expect(restored.username, equals(user.username));
      expect(restored.email, equals(user.email));
      expect(restored.preferredCategories, equals(user.preferredCategories));
    });

    test('toDb / fromDb round-trip', () {
      final db = user.toDb();
      final restored = User.fromDb(db);
      expect(restored.username, equals(user.username));
      expect(restored.preferredCategories, equals(user.preferredCategories));
    });

    test('preferredCategories defaults to empty list', () {
      const u = User(
          id: 2, username: 'guest', email: 'g@x.com', password: 'pw');
      expect(u.preferredCategories, isEmpty);
    });

    test('copyWith updates fields correctly', () {
      final updated = user.copyWith(username: 'new_name');
      expect(updated.username, equals('new_name'));
      expect(updated.email, equals(user.email));
    });
  });

  // ─── Place ───────────────────────────────────────────────────────────────

  group('Place serialization', () {
    const place = Place(
      placeId: 'ChIJabc123',
      name: 'Bahrain National Museum',
      category: 'attraction',
      rating: 4.5,
      priceLevel: 1,
      address: 'Building 144, Al-Fateh Highway',
      latitude: 26.2285,
      longitude: 50.5860,
      description: 'A great museum.',
      photoReference: 'photo_ref_abc',
      openNow: true,
    );

    test('placeId is a String (not int)', () {
      expect(place.placeId, isA<String>());
      expect(place.placeId, equals('ChIJabc123'));
    });

    test('priceLevel is an int', () {
      expect(place.priceLevel, isA<int>());
    });

    test('toJson / fromJson round-trip', () {
      final json = place.toJson();
      final restored = Place.fromJson(json);
      expect(restored.placeId, equals(place.placeId));
      expect(restored.name, equals(place.name));
      expect(restored.rating, equals(place.rating));
      expect(restored.priceLevel, equals(place.priceLevel));
      expect(restored.photoReference, equals(place.photoReference));
      expect(restored.openNow, equals(place.openNow));
    });

    test('toDb / fromDb round-trip (openNow stored as int)', () {
      final db = place.toDb();
      expect(db['open_now'], equals(1)); // true → 1
      final restored = Place.fromDb(db);
      expect(restored.openNow, isTrue);
      expect(restored.placeId, equals(place.placeId));
    });

    test('openNow false stored as 0', () {
      const closed = Place(
          placeId: 'x', name: 'x', category: 'cafe',
          latitude: 0, longitude: 0, openNow: false);
      expect(closed.toDb()['open_now'], equals(0));
    });

    test('openNow null stored as null', () {
      const noStatus = Place(
          placeId: 'x', name: 'x', category: 'cafe',
          latitude: 0, longitude: 0);
      expect(noStatus.toDb()['open_now'], isNull);
    });

    test('priceLevelDisplay returns dollar signs', () {
      const p2 = Place(placeId: 'x', name: 'x', category: 'cafe',
          latitude: 0, longitude: 0, priceLevel: 2);
      expect(p2.priceLevelDisplay, equals('\$\$'));
    });

    test('priceLevelDisplay returns Free for 0', () {
      const p0 = Place(placeId: 'x', name: 'x', category: 'cafe',
          latitude: 0, longitude: 0, priceLevel: 0);
      expect(p0.priceLevelDisplay, equals('Free'));
    });

    test('copyWith updates fields correctly', () {
      final updated = place.copyWith(name: 'Updated Museum');
      expect(updated.name, equals('Updated Museum'));
      expect(updated.placeId, equals(place.placeId));
    });
  });

  // ─── ItineraryPlace ──────────────────────────────────────────────────────

  group('ItineraryPlace serialization', () {
    const ip = ItineraryPlace(
      id: 1,
      itineraryId: 10,
      placeId: 'ChIJabc123',
      timeSlot: 'morning',
      orderIndex: 0,
    );

    test('toJson / fromJson round-trip', () {
      final json = ip.toJson();
      final restored = ItineraryPlace.fromJson(json);
      expect(restored.placeId, equals(ip.placeId));
      expect(restored.timeSlot, equals(ip.timeSlot));
      expect(restored.orderIndex, equals(ip.orderIndex));
    });

    test('toDb / fromDb round-trip', () {
      final db = ip.toDb();
      final restored = ItineraryPlace.fromDb(db);
      expect(restored.itineraryId, equals(ip.itineraryId));
      expect(restored.placeId, equals(ip.placeId));
      expect(restored.timeSlot, equals(ip.timeSlot));
    });

    test('timeSlot is one of the valid values', () {
      const validSlots = ['morning', 'afternoon', 'evening'];
      expect(validSlots, contains(ip.timeSlot));
    });

    test('copyWith updates itineraryId', () {
      final updated = ip.copyWith(itineraryId: 99);
      expect(updated.itineraryId, equals(99));
      expect(updated.placeId, equals(ip.placeId));
    });
  });

  // ─── Itinerary ───────────────────────────────────────────────────────────

  group('Itinerary serialization', () {
    final now = DateTime(2026, 2, 24);
    final itinerary = Itinerary(
      id: 1,
      userId: 5,
      city: 'Manama',
      name: 'Weekend Trip',
      date: now,
      createdAt: now,
      places: const [
        ItineraryPlace(
          itineraryId: 1,
          placeId: 'ChIJabc123',
          timeSlot: 'morning',
          orderIndex: 0,
        ),
      ],
    );

    test('toJson / fromJson round-trip', () {
      final json = itinerary.toJson();
      final restored = Itinerary.fromJson(json);
      expect(restored.city, equals(itinerary.city));
      expect(restored.userId, equals(itinerary.userId));
      expect(restored.name, equals(itinerary.name));
      expect(restored.places.length, equals(1));
    });

    test('toDb / fromDb round-trip (date as ISO string)', () {
      final db = itinerary.toDb();
      expect(db['date'], isA<String>());
      final restored = Itinerary.fromDb(db);
      expect(restored.city, equals(itinerary.city));
      expect(restored.date.year, equals(2026));
    });

    test('copyWith updates name', () {
      final updated = itinerary.copyWith(name: 'New Name');
      expect(updated.name, equals('New Name'));
      expect(updated.city, equals(itinerary.city));
    });

    test('places defaults to empty list', () {
      final it = Itinerary(
        userId: 1, city: 'X', name: 'Y',
        date: now, createdAt: now,
      );
      expect(it.places, isEmpty);
    });
  });
}
