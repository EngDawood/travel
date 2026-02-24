# Mini Travel Assistant — Implementation Spec

## 1. Project Overview

A **Flutter mobile app** that helps travelers generate organized daily itineraries for any city. Users select a destination and preference categories, the app fetches real-time place data from Google Places API, and organizes results into a morning/afternoon/evening daily plan.

**Target platforms:** Android 5.0+, iOS 11.0+

---

## 2. Tech Stack

| Layer | Technology |
|---|---|
| Framework | Flutter (Dart) |
| State Management | Provider |
| Local Database | SQLite via `sqflite` package |
| Local Preferences | `shared_preferences` |
| HTTP Client | `http` package |
| Maps | `google_maps_flutter` |
| Places Data | Google Places API (New) — REST |
| Serialization | `json_serializable` + `build_runner` |
| Auth (optional) | Firebase Auth |
| Navigation | GoRouter |

---

## 3. Architecture

Client-server, 3-layer on the client side:

```
┌─────────────────────────────────┐
│         UI Layer (Screens)      │
├─────────────────────────────────┤
│   Business Logic (Providers)    │
├─────────────────────────────────┤
│   Data Layer                    │
│   ├── APIService (Google APIs)  │
│   ├── DatabaseHelper (SQLite)   │
│   └── PreferencesService        │
└─────────────────────────────────┘
          │
          ▼  HTTP/HTTPS
┌─────────────────────────────────┐
│   Google Places API             │
│   Google Maps SDK               │
│   Firebase (optional)           │
└─────────────────────────────────┘
```

---

## 4. Project Structure

```
lib/
├── main.dart
├── app.dart                    # MaterialApp + Router setup
├── config/
│   ├── constants.dart          # API keys, base URLs, enums
│   └── theme.dart
├── models/
│   ├── user.dart
│   ├── place.dart
│   ├── itinerary.dart
│   └── itinerary_place.dart
├── services/
│   ├── api_service.dart        # Google Places API calls
│   ├── database_helper.dart    # SQLite CRUD
│   └── preferences_service.dart
├── providers/
│   ├── auth_provider.dart
│   ├── places_provider.dart
│   ├── itinerary_provider.dart
│   └── map_provider.dart
├── screens/
│   ├── home_screen.dart
│   ├── city_search_screen.dart
│   ├── preferences_screen.dart # Category selection
│   ├── places_list_screen.dart
│   ├── place_detail_screen.dart
│   ├── itinerary_screen.dart   # Generated daily plan
│   ├── saved_itineraries_screen.dart
│   └── map_screen.dart
├── widgets/
│   ├── place_card.dart
│   ├── time_slot_section.dart  # morning/afternoon/evening
│   ├── itinerary_tile.dart
│   └── category_chip.dart
└── utils/
    ├── itinerary_generator.dart # Sorting/scheduling logic
    └── helpers.dart
```

---

## 5. Data Models

### 5.1 User

```dart
class User {
  final int? id;
  final String username;
  final String email;
  final String password; // hashed
  final List<String> preferredCategories;
}
```

Storage: SQLite `users` table.

### 5.2 Place

```dart
class Place {
  final String placeId;       // Google Place ID (string, NOT int)
  final String name;
  final String category;      // restaurant | attraction | shopping | cafe | nightlife
  final double rating;
  final int priceLevel;       // 0-4 from Google
  final String address;
  final double latitude;
  final double longitude;
  final String? description;
  final String? photoReference; // Google photo reference, NOT a URL
  final bool? openNow;
}
```

**Important corrections from the report:**
- `PlaceID` must be a **String** (Google Place IDs are strings like `ChIJ...`), not `int`.
- `PriceLevel` is an **int** (0–4), not a string.
- `PhotoURL` should be `photoReference` — you construct the URL at runtime using the Places Photos API.
- Add `openNow` field for real-time status.

### 5.3 Itinerary

```dart
class Itinerary {
  final int? id;
  final int userId;
  final String city;
  final String name;        // user-given name
  final DateTime date;
  final DateTime createdAt;
  final List<ItineraryPlace> places; // populated via join
}
```

### 5.4 ItineraryPlace (junction)

```dart
class ItineraryPlace {
  final int? id;
  final int itineraryId;
  final String placeId;
  final String timeSlot;    // "morning" | "afternoon" | "evening"
  final int orderIndex;
}
```

---

## 6. Database Schema (SQLite)

```sql
CREATE TABLE users (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  username TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  password TEXT NOT NULL,
  preferred_categories TEXT  -- JSON array stored as string
);

CREATE TABLE places (
  place_id TEXT PRIMARY KEY,  -- Google Place ID
  name TEXT NOT NULL,
  category TEXT NOT NULL,
  rating REAL DEFAULT 0,
  price_level INTEGER DEFAULT 0,
  address TEXT,
  latitude REAL NOT NULL,
  longitude REAL NOT NULL,
  description TEXT,
  photo_reference TEXT,
  open_now INTEGER           -- 0 or 1
);

CREATE TABLE itineraries (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  user_id INTEGER NOT NULL,
  city TEXT NOT NULL,
  name TEXT,
  date TEXT NOT NULL,         -- ISO 8601
  created_at TEXT NOT NULL,
  FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE TABLE itinerary_places (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  itinerary_id INTEGER NOT NULL,
  place_id TEXT NOT NULL,
  time_slot TEXT NOT NULL CHECK(time_slot IN ('morning','afternoon','evening')),
  order_index INTEGER NOT NULL,
  FOREIGN KEY (itinerary_id) REFERENCES itineraries(id) ON DELETE CASCADE,
  FOREIGN KEY (place_id) REFERENCES places(place_id)
);
```

---

## 7. Core Features & Screens

### 7.1 Home Screen
- Welcome message
- Quick action: "Plan a Trip" button
- List of saved itineraries (recent 3)

### 7.2 City Search
- Text field with autocomplete (Google Places Autocomplete API)
- On city select → navigate to preferences

### 7.3 Category Preferences
- Chips for: Restaurants, Cafes, Attractions, Shopping, Nightlife
- Multi-select, at least 1 required
- "Generate Plan" button

### 7.4 Places List
- Fetched from Google Places API (Nearby Search) for selected city + categories
- Each card shows: name, rating (stars), price level ($–$$$$), photo, category tag
- Tap → Place Detail
- "Add to itinerary" toggle per place
- FAB: "Generate Itinerary" when ≥3 places selected

### 7.5 Place Detail
- Full info: name, rating, price, address, description, photo, open status
- "View on Map" button
- "Add to Itinerary" button

### 7.6 Map Screen
- Google Map with markers for selected/recommended places
- Tap marker → info window → navigate to detail
- Optional: show route between places

### 7.7 Generated Itinerary
- 3 sections: **Morning**, **Afternoon**, **Evening**
- Each section lists places in order with time estimates
- "Save Itinerary" button → prompts for name → saves to SQLite
- "Edit" → reorder / remove places
- "Share" (optional stretch)

### 7.8 Saved Itineraries
- List of all saved plans
- Swipe to delete
- Tap to view details
- Edit button per itinerary

---

## 8. Itinerary Generation Logic

File: `lib/utils/itinerary_generator.dart`

```
Input: List<Place> selectedPlaces, int maxPerSlot (default 2-3)
Output: Map<String, List<Place>> → { morning: [...], afternoon: [...], evening: [...] }

Algorithm:
1. Sort places by category priority:
   - Morning: cafes, attractions
   - Afternoon: attractions, shopping
   - Evening: restaurants, nightlife
2. Within each slot, sort by rating (desc), then by distance from previous place
3. Cap each slot at maxPerSlot places
4. If places remain unassigned, distribute to slots with fewest items
5. Assign orderIndex sequentially within each slot
```

---

## 9. API Service

### 9.1 Endpoints Used

| Purpose | Google API Endpoint |
|---|---|
| City autocomplete | Places Autocomplete |
| Search places by category | Nearby Search |
| Place details | Place Details |
| Place photo | Place Photos |

### 9.2 Key Methods

```dart
class APIService {
  final String apiKey;
  final String baseUrl = 'https://maps.googleapis.com/maps/api/place';

  Future<List<Place>> searchNearby({
    required double lat,
    required double lng,
    required String type,     // restaurant, tourist_attraction, etc.
    int radius = 5000,
  });

  Future<Place> getPlaceDetails(String placeId);

  String getPhotoUrl(String photoReference, {int maxWidth = 400});

  Future<List<Map<String, dynamic>>> autocompleteCity(String input);
}
```

### 9.3 Google Place Types Mapping

| App Category | Google Place Type(s) |
|---|---|
| Restaurants | `restaurant` |
| Cafes | `cafe` |
| Attractions | `tourist_attraction`, `museum`, `park` |
| Shopping | `shopping_mall`, `store` |
| Nightlife | `bar`, `night_club` |

---

## 10. State Management (Provider)

### PlacesProvider
- `List<Place> fetchedPlaces`
- `List<Place> selectedPlaces`
- `bool isLoading`
- Methods: `fetchPlaces(city, categories)`, `toggleSelect(place)`, `clearSelection()`

### ItineraryProvider
- `Itinerary? currentItinerary`
- `List<Itinerary> savedItineraries`
- Methods: `generateItinerary(selectedPlaces)`, `saveItinerary(name)`, `loadSaved()`, `deleteItinerary(id)`, `editItinerary(id, changes)`

### AuthProvider (simple/local)
- `User? currentUser`
- Methods: `login(email, password)`, `register(...)`, `logout()`, `updatePreferences(categories)`

---

## 11. Error Handling

- API failures → show SnackBar with retry option
- No internet → detect with `connectivity_plus`, show offline message
- Empty results → "No places found. Try different categories or a broader area."
- API quota exceeded → graceful message, suggest trying later
- SQLite errors → log + generic user message

---

## 12. Dependencies (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.0
  sqflite: ^2.3.0
  path: ^1.8.0
  http: ^1.2.0
  google_maps_flutter: ^2.5.0
  shared_preferences: ^2.2.0
  go_router: ^13.0.0
  json_annotation: ^4.8.0
  connectivity_plus: ^5.0.0
  cached_network_image: ^3.3.0
  flutter_rating_bar: ^4.0.1
  intl: ^0.19.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  build_runner: ^2.4.0
  json_serializable: ^6.7.0
```

---

## 13. Environment Setup

1. Get a **Google Cloud API key** with these APIs enabled:
   - Places API (New)
   - Maps SDK for Android
   - Maps SDK for iOS
   - Geocoding API

2. Store the key in `lib/config/constants.dart` (for dev) or use `--dart-define` for builds:
   ```
   flutter run --dart-define=GOOGLE_API_KEY=your_key_here
   ```

3. Android: Add key to `android/app/src/main/AndroidManifest.xml`
4. iOS: Add key to `ios/Runner/AppDelegate.swift`

---

## 14. Build Order (Recommended)

Implement in this sequence:

1. **Project scaffold** — folder structure, theme, routing
2. **Models** — all 4 data classes with JSON serialization
3. **Database Helper** — SQLite setup, all CRUD methods
4. **API Service** — Google Places integration
5. **Providers** — wire up state management
6. **City Search Screen** — autocomplete
7. **Preferences Screen** — category selection
8. **Places List Screen** — fetch & display
9. **Place Detail Screen**
10. **Itinerary Generator** — scheduling algorithm
11. **Itinerary Screen** — display generated plan
12. **Save/Load** — saved itineraries CRUD
13. **Map Screen** — Google Maps with markers
14. **Auth** (if time permits) — local user registration/login
15. **Polish** — error handling, loading states, empty states

---

## 15. Testing Plan

### Unit Tests
- `itinerary_generator_test.dart` — verify slot assignment logic
- `api_service_test.dart` — mock HTTP, verify parsing
- `database_helper_test.dart` — CRUD operations

### Widget Tests
- Place card renders correctly
- Category chips toggle state
- Itinerary screen shows 3 time slots

### Integration Tests
- Full flow: search city → select categories → view places → generate itinerary → save → view saved

---

## 16. Known Constraints

- Google Places API free tier: $200/month credit (~$0.032 per Nearby Search call)
- Autocomplete billed per session — use session tokens
- Photos API requires `photoReference`, not direct URLs
- Offline mode limited to previously cached/saved data only
- No AI/ML predictions — purely rule-based itinerary sorting
- No hotel booking or transportation integration (future work)

---

## 17. What the Report Got Wrong (for reference)

| Report Claim | Actual |
|---|---|
| PlaceID is `int` | Must be `String` (Google Place IDs are strings) |
| PriceLevel is `string` | Should be `int` (0–4) |
| PhotoURL stored directly | Should store `photoReference`, construct URL at runtime |
| Ch 5 "Implementation" is empty | This spec covers it fully |
| Ch 6 "Testing" is placeholder | See Section 15 above |
| Ch 7 "Conclusion" is placeholder | N/A for coding |
| Section numbering is inconsistent (3.2.1 repeated, 5.1/5.2 misordered) | Fixed in this spec |
| Page numbering says "Page X of 41" but goes to page 53 | Cosmetic, not code-relevant |
| Abbreviation list includes irrelevant terms (AES, ISDN, WAP, etc.) | Not used in the project |
