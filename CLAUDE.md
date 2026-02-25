# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

Flutter mobile app — "Mini Travel Assistant" — generates daily travel itineraries using Google Places API.

- Full implementation spec: `docs/spec.md` (read before writing any code)
- Database schema: `docs/database_schema.sql`
- Sample API responses: `docs/api_examples.json`
- Enhancement roadmap: `docs/ENHANCEMENTS.md` (do not touch until core is complete)

## Commands

```bash
# Install dependencies
flutter pub get

# Regenerate JSON serialization code (after modifying models)
dart run build_runner build

# Run app (mock API, no key needed)
flutter run

# Run app with real Google Places API key
flutter run --dart-define=GOOGLE_API_KEY=your_key_here

# Run all tests
flutter test

# Static analysis
flutter analyze

# Build release APK
flutter build apk --dart-define=GOOGLE_API_KEY=your_key_here
```

## Architecture

Clean 3-layer architecture: **UI (screens/widgets) → Providers → Services/DB**

```
lib/
├── main.dart               # Entry point: MultiProvider setup
├── app.dart                # GoRouter configuration
├── config/                 # API key, enums (TimeSlot, PlaceCategory), Material 3 theme
├── models/                 # User, Place, Itinerary, ItineraryPlace — all @JsonSerializable
├── services/               # ApiService (Google Places REST), DatabaseHelper (SQLite singleton),
│                           # PreferencesService (SharedPreferences), mock_api_service
│   └── db/                 # DbInterface (abstract), db_sqlite.dart (mobile/desktop), db_memory.dart (web)
├── providers/              # AuthProvider, PlacesProvider, ItineraryProvider, MapProvider
├── screens/                # 8 screens (home, auth, city_search, preferences, places_list,
│                           # place_detail, itinerary, saved_itineraries, map)
├── widgets/                # Reusable components (category_chip, place_card, itinerary_tile, etc.)
└── utils/                  # itinerary_generator.dart (slot assignment algorithm), helpers.dart
```

**State management:** Provider (ChangeNotifier) — not Riverpod, not Bloc, not GetX
**Navigation:** GoRouter — not Navigator 1.0
**Database:** sqflite (mobile/desktop) + in-memory (web), abstracted via `DbInterface`
**Models:** `json_serializable` with `@JsonSerializable()` — run `build_runner` after any model change

## Key Constraints

- `placeId` is a **String** (Google Place IDs like `ChIJ...`), never int
- `priceLevel` is an **int** (0–4), never string
- Store photo **references** (not full URLs); construct at runtime via `ApiService.getPhotoUrl()`
- Google API key comes from `--dart-define=GOOGLE_API_KEY=...`, never hardcoded
- Use the Places API (New) endpoints; fall back to legacy Nearby Search only if needed
- Local SQLite auth only — no Firebase unless explicitly requested

## Testing

35 unit tests across:
- `test/itinerary_generator_test.dart` — slot assignment algorithm (13 tests)
- `test/model_serialization_test.dart` — JSON/DB serialization for all models (22 tests)
- `test/widget_test.dart` — app smoke test (1 test)
