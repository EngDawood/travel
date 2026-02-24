// lib/utils/itinerary_generator.dart
import '../config/constants.dart';
import '../models/itinerary.dart';
import '../models/itinerary_place.dart';
import '../models/place.dart';

class ItineraryGenerator {
  /// Assigns places to morning/afternoon/evening slots based on category.
  /// Returns a map of timeSlot → ordered list of places.
  static Map<String, List<Place>> generate(
    List<Place> places, {
    int maxPerSlot = maxPlacesPerSlot,
  }) {
    final slots = <String, List<Place>>{
      'morning': [],
      'afternoon': [],
      'evening': [],
    };

    // Category → preferred slot(s) in priority order
    const slotPriority = {
      'cafe': ['morning', 'afternoon'],
      'attraction': ['morning', 'afternoon'],
      'shopping': ['afternoon', 'morning'],
      'restaurant': ['evening', 'afternoon'],
      'nightlife': ['evening'],
    };

    // Make a working copy sorted by rating desc
    final sorted = [...places]..sort((a, b) => b.rating.compareTo(a.rating));

    final assigned = <String>{};

    // First pass — assign by preferred slot
    for (final place in sorted) {
      final priorities =
          slotPriority[place.category] ?? ['morning', 'afternoon', 'evening'];
      for (final slot in priorities) {
        if (!assigned.contains(place.placeId) &&
            slots[slot]!.length < maxPerSlot) {
          slots[slot]!.add(place);
          assigned.add(place.placeId);
          break;
        }
      }
    }

    // Second pass — distribute remaining places to slots with room
    for (final place in sorted) {
      if (assigned.contains(place.placeId)) continue;
      for (final slot in ['morning', 'afternoon', 'evening']) {
        if (slots[slot]!.length < maxPerSlot) {
          slots[slot]!.add(place);
          assigned.add(place.placeId);
          break;
        }
      }
    }

    return slots;
  }

  /// Build an [Itinerary] object from a slot map.
  static Itinerary buildItinerary({
    required Map<String, List<Place>> slotMap,
    required String city,
    required int userId,
    String name = '',
  }) {
    final now = DateTime.now();
    final itineraryPlaces = <ItineraryPlace>[];

    slotMap.forEach((slot, places) {
      for (int i = 0; i < places.length; i++) {
        itineraryPlaces.add(ItineraryPlace(
          itineraryId: 0, // will be set on save
          placeId: places[i].placeId,
          timeSlot: slot,
          orderIndex: i,
        ));
      }
    });

    return Itinerary(
      userId: userId,
      city: city,
      name: name,
      date: now,
      createdAt: now,
      places: itineraryPlaces,
    );
  }
}
