// lib/config/constants.dart

/// Google Places API key.
/// Pass via: flutter run --dart-define=GOOGLE_API_KEY=your_key_here
const String googleApiKey = String.fromEnvironment(
  'GOOGLE_API_KEY',
  defaultValue: 'YOUR_API_KEY_HERE',
);

/// Set to true to use MockApiService instead of real Google Places API.
/// Automatically enabled when no real API key is provided.
bool get useMockApi => googleApiKey == 'YOUR_API_KEY_HERE';

const String placesBaseUrl = 'https://maps.googleapis.com/maps/api/place';

/// App-wide constants
const int maxPlacesPerSlot = 3;
const int nearbySearchRadius = 5000; // meters

/// Time slot labels
enum TimeSlot { morning, afternoon, evening }

extension TimeSlotExtension on TimeSlot {
  String get label {
    switch (this) {
      case TimeSlot.morning:
        return 'morning';
      case TimeSlot.afternoon:
        return 'afternoon';
      case TimeSlot.evening:
        return 'evening';
    }
  }

  String get displayName {
    switch (this) {
      case TimeSlot.morning:
        return 'Morning';
      case TimeSlot.afternoon:
        return 'Afternoon';
      case TimeSlot.evening:
        return 'Evening';
    }
  }
}

/// Place categories used in the app
enum PlaceCategory { restaurant, cafe, attraction, shopping, nightlife }

extension PlaceCategoryExtension on PlaceCategory {
  String get label {
    switch (this) {
      case PlaceCategory.restaurant:
        return 'restaurant';
      case PlaceCategory.cafe:
        return 'cafe';
      case PlaceCategory.attraction:
        return 'attraction';
      case PlaceCategory.shopping:
        return 'shopping';
      case PlaceCategory.nightlife:
        return 'nightlife';
    }
  }

  String get displayName {
    switch (this) {
      case PlaceCategory.restaurant:
        return 'Restaurants';
      case PlaceCategory.cafe:
        return 'Cafes';
      case PlaceCategory.attraction:
        return 'Attractions';
      case PlaceCategory.shopping:
        return 'Shopping';
      case PlaceCategory.nightlife:
        return 'Nightlife';
    }
  }

  /// Maps app category to Google Place API type(s)
  List<String> get googleTypes {
    switch (this) {
      case PlaceCategory.restaurant:
        return ['restaurant'];
      case PlaceCategory.cafe:
        return ['cafe'];
      case PlaceCategory.attraction:
        return ['tourist_attraction', 'museum', 'park'];
      case PlaceCategory.shopping:
        return ['shopping_mall', 'store'];
      case PlaceCategory.nightlife:
        return ['bar', 'night_club'];
    }
  }
}
