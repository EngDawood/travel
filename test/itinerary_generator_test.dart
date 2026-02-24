// test/itinerary_generator_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:travel/config/constants.dart';
import 'package:travel/models/place.dart';
import 'package:travel/utils/itinerary_generator.dart';

Place _place(String id, String category, double rating) => Place(
      placeId: id,
      name: 'Place $id',
      category: category,
      rating: rating,
      latitude: 0,
      longitude: 0,
    );

void main() {
  group('ItineraryGenerator.generate', () {
    test('assigns cafes to morning slot', () {
      final places = [_place('1', 'cafe', 4.0)];
      final result = ItineraryGenerator.generate(places);
      expect(result['morning'], contains(predicate<Place>((p) => p.placeId == '1')));
    });

    test('assigns restaurants to evening slot', () {
      final places = [_place('1', 'restaurant', 4.0)];
      final result = ItineraryGenerator.generate(places);
      expect(result['evening'], contains(predicate<Place>((p) => p.placeId == '1')));
    });

    test('assigns nightlife to evening slot', () {
      final places = [_place('1', 'nightlife', 4.0)];
      final result = ItineraryGenerator.generate(places);
      expect(result['evening'], contains(predicate<Place>((p) => p.placeId == '1')));
    });

    test('assigns attractions to morning slot first', () {
      final places = [_place('1', 'attraction', 4.5)];
      final result = ItineraryGenerator.generate(places);
      expect(result['morning'], contains(predicate<Place>((p) => p.placeId == '1')));
    });

    test('caps each slot at maxPlacesPerSlot', () {
      final places = List.generate(
          10, (i) => _place('cafe_$i', 'cafe', 4.0 - i * 0.1));
      final result = ItineraryGenerator.generate(places);
      for (final slot in result.values) {
        expect(slot.length, lessThanOrEqualTo(maxPlacesPerSlot));
      }
    });

    test('no place is assigned twice', () {
      final places = [
        _place('1', 'cafe', 4.0),
        _place('2', 'restaurant', 3.5),
        _place('3', 'attraction', 4.8),
        _place('4', 'shopping', 3.0),
        _place('5', 'nightlife', 4.2),
      ];
      final result = ItineraryGenerator.generate(places);
      final allAssigned = [
        ...result['morning']!,
        ...result['afternoon']!,
        ...result['evening']!,
      ].map((p) => p.placeId).toList();

      expect(allAssigned.toSet().length, equals(allAssigned.length));
    });

    test('all places are assigned when count <= total capacity', () {
      final places = [
        _place('1', 'cafe', 4.0),
        _place('2', 'restaurant', 3.5),
        _place('3', 'attraction', 4.8),
      ];
      final result = ItineraryGenerator.generate(places);
      final totalAssigned = result.values.fold(0, (s, l) => s + l.length);
      expect(totalAssigned, equals(3));
    });

    test('higher rated places appear before lower rated in same slot', () {
      final places = [
        _place('low', 'cafe', 2.0),
        _place('high', 'cafe', 5.0),
        _place('mid', 'cafe', 3.5),
      ];
      final result = ItineraryGenerator.generate(places);
      final morning = result['morning']!;
      if (morning.length >= 2) {
        expect(morning.first.rating,
            greaterThanOrEqualTo(morning.last.rating));
      }
    });

    test('overflow places fill slots with room', () {
      // Fill morning and afternoon with cafes/attractions, overflow should go to evening
      final places = [
        _place('c1', 'cafe', 5.0),
        _place('c2', 'cafe', 4.9),
        _place('c3', 'cafe', 4.8),
        _place('a1', 'attraction', 4.7),
        _place('a2', 'attraction', 4.6),
        _place('a3', 'attraction', 4.5),
        _place('s1', 'shopping', 4.4),
      ];
      final result = ItineraryGenerator.generate(places);
      final totalAssigned = result.values.fold(0, (s, l) => s + l.length);
      // Total capacity is 3 slots × maxPlacesPerSlot
      expect(totalAssigned, lessThanOrEqualTo(3 * maxPlacesPerSlot));
      expect(totalAssigned, greaterThan(0));
    });

    test('returns empty slots for empty input', () {
      final result = ItineraryGenerator.generate([]);
      expect(result['morning'], isEmpty);
      expect(result['afternoon'], isEmpty);
      expect(result['evening'], isEmpty);
    });
  });

  group('ItineraryGenerator.buildItinerary', () {
    test('builds itinerary with correct city and userId', () {
      final slotMap = {
        'morning': [_place('1', 'cafe', 4.0)],
        'afternoon': <Place>[],
        'evening': <Place>[],
      };
      final result = ItineraryGenerator.buildItinerary(
        slotMap: slotMap,
        city: 'Manama',
        userId: 42,
      );
      expect(result.city, equals('Manama'));
      expect(result.userId, equals(42));
    });

    test('assigns correct timeSlot to each place', () {
      final slotMap = {
        'morning': [_place('m1', 'cafe', 4.0)],
        'afternoon': [_place('a1', 'shopping', 3.5)],
        'evening': [_place('e1', 'restaurant', 4.5)],
      };
      final result = ItineraryGenerator.buildItinerary(
        slotMap: slotMap,
        city: 'Manama',
        userId: 1,
      );
      final morning = result.places.where((p) => p.timeSlot == 'morning');
      final afternoon = result.places.where((p) => p.timeSlot == 'afternoon');
      final evening = result.places.where((p) => p.timeSlot == 'evening');

      expect(morning.map((p) => p.placeId), contains('m1'));
      expect(afternoon.map((p) => p.placeId), contains('a1'));
      expect(evening.map((p) => p.placeId), contains('e1'));
    });

    test('orderIndex is sequential within each slot', () {
      final slotMap = {
        'morning': [_place('1', 'cafe', 5.0), _place('2', 'cafe', 4.0)],
        'afternoon': <Place>[],
        'evening': <Place>[],
      };
      final result = ItineraryGenerator.buildItinerary(
        slotMap: slotMap,
        city: 'Test',
        userId: 1,
      );
      final morning = result.places
          .where((p) => p.timeSlot == 'morning')
          .toList()
        ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));
      expect(morning[0].orderIndex, equals(0));
      expect(morning[1].orderIndex, equals(1));
    });
  });
}
