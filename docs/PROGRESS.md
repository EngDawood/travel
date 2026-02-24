# PROGRESS.md — Implementation Log

> Tracks what has been built, file by file, following the build order in spec.md Section 14.

---

## Status: Steps 1–14 Complete

---

## Step 1 — Project Scaffold ✅

**Files created:**
- `pubspec.yaml` — all dependencies from spec added (+ `crypto` for password hashing)
- `lib/config/constants.dart` — API key placeholder, `TimeSlot` enum, `PlaceCategory` enum with `googleTypes` mapping
- `lib/config/theme.dart` — MaterialApp theme (colors, cards, buttons, inputs, chips)
- `lib/app.dart` — `TravelApp` widget, GoRouter with all 9 routes, session restore on startup
- `lib/main.dart` — clean entry point with `MultiProvider`
- `lib/screens/` — all 8 placeholder screens created

---

## Step 2 — Models ✅

**Files created:**
- `lib/models/user.dart` — `User` with `fromDb`/`toDb`, JSON array stored as string for `preferredCategories`
- `lib/models/place.dart` — `Place` with `photoReference` (not URL), `priceLevel` as int, `openNow` as bool
- `lib/models/itinerary.dart` — `Itinerary` with `List<ItineraryPlace>` populated via join
- `lib/models/itinerary_place.dart` — junction model with `timeSlot` and `orderIndex`

**Generated (build_runner):**
- `lib/models/user.g.dart`
- `lib/models/place.g.dart`
- `lib/models/itinerary.g.dart`
- `lib/models/itinerary_place.g.dart`

**Command run:** `dart run build_runner build`

---

## Step 3 — Database Helper ✅

**Files created:**
- `lib/services/database_helper.dart` — singleton SQLite helper

**Covers:**
- `_onCreate` — creates all 4 tables matching `database_schema.sql` exactly
- Users: `insertUser`, `getUserByEmail`, `getUserById`, `updateUser`, `updateUserCategories`, `deleteUser`
- Places: `upsertPlace`, `upsertPlaces` (batch), `getPlace`, `getPlacesByCategory`, `deletePlace`
- Itineraries: `insertItinerary` (with junction rows), `getItinerary`, `getItinerariesForUser`, `updateItineraryName`, `deleteItinerary`, `replaceItineraryPlaces`

---

## Step 4 — API Service ✅

**Files created:**
- `lib/services/api_service.dart`

**Covers:**
- `searchNearby()` — single type Nearby Search
- `searchNearbyMultiple()` — all selected categories, deduped by `placeId`
- `getPlaceDetails()` — full place info including description and photos
- `getPhotoUrl()` — constructs photo URL from `photoReference` at runtime (no HTTP call)
- `autocompleteCity()` — city autocomplete filtered to `(cities)` type
- `getCityLatLng()` — resolves city `placeId` to lat/lng
- `ApiException` — custom exception for clean error propagation

---

## Step 5 — Providers ✅

**Files created:**
- `lib/services/preferences_service.dart` — `SharedPreferences` wrapper for session persistence
- `lib/providers/auth_provider.dart` — register, login, logout, `restoreSession`, SHA-256 password hashing via `crypto`
- `lib/providers/places_provider.dart` — `fetchPlaces`, `toggleSelect`, `isSelected`, `clearSelection`, `reset`
- `lib/providers/itinerary_provider.dart` — `generateItinerary`, `saveItinerary`, `loadSaved`, `deleteItinerary`, `renameItinerary`, `viewItinerary`
- `lib/providers/map_provider.dart` — `setPlaces` (builds markers), `selectPlace`, `clearSelection`
- `lib/utils/itinerary_generator.dart` — slot assignment algorithm (category priority → rating sort → overflow distribution)
- `lib/utils/helpers.dart` — `formatDate`, `priceLevelToString`, `capitalize`
- `lib/main.dart` — updated with `MultiProvider` wrapping all 4 providers

---

## Step 6 — City Search Screen ✅

**Files updated:**
- `lib/screens/city_search_screen.dart`

**Features:**
- Text field with live autocomplete (triggers after 2 characters)
- Calls `ApiService.autocompleteCity()` on each change
- On city select → calls `getCityLatLng()` → sets city in `PlacesProvider` → navigates to `/preferences`
- Loading indicator, error display, clear button

---

## Step 7 — Preferences Screen ✅

**Files updated/created:**
- `lib/screens/preferences_screen.dart`
- `lib/widgets/category_chip.dart` — animated chip with icon, selected state highlight

**Features:**
- Multi-select chips for all 5 categories
- Requires at least 1 selection
- "Find Places" button triggers `PlacesProvider.fetchPlaces()` then navigates to `/places`

---

## Step 8 — Places List Screen ✅

**Files updated/created:**
- `lib/screens/places_list_screen.dart`
- `lib/widgets/place_card.dart` — photo, name, rating bar, price level, category tag, open/closed status, add/remove toggle

**Features:**
- Loading, error, and empty states
- Each card shows photo (via `CachedNetworkImage`), rating (`flutter_rating_bar`), price, category, open status
- Tap card → `/place/:id`
- Tap `+` icon → toggles selection in `PlacesProvider`
- FAB "Generate Itinerary" appears when ≥ 3 places selected
- Selection counter in app bar

---

## Step 9 — Place Detail Screen ✅

**Files updated:**
- `lib/screens/place_detail_screen.dart`

**Features:**
- Loads from SQLite cache first, falls back to API
- Hero photo in `SliverAppBar`
- Name, open/closed badge, rating bar, price level, address, description
- "View on Map" → `/map`
- "Add to Itinerary" / "Added" toggle button

---

## Step 10 — Itinerary Generator ✅

**Files created:**
- `lib/utils/itinerary_generator.dart`

**Algorithm:**
1. Sort all places by rating descending
2. Assign to preferred slot by category (cafes/attractions → morning, attractions/shopping → afternoon, restaurants/nightlife → evening)
3. Cap each slot at `maxPlacesPerSlot` (default 3)
4. Distribute remaining unassigned places to slots with room
5. Build `Itinerary` object with `ItineraryPlace` junction rows

---

## Step 11 — Itinerary Screen ✅

**Files updated/created:**
- `lib/screens/itinerary_screen.dart`
- `lib/widgets/time_slot_section.dart` — morning/afternoon/evening section with icon, color, time range
- `lib/widgets/itinerary_tile.dart` — numbered tile with place name, category, rating, price

**Features:**
- 3 time slot sections with color coding (orange/blue/indigo)
- Edit mode: removes places from slots
- "Save Itinerary" → dialog prompts for name → saves to SQLite → navigates to `/saved`
- Summary banner shows date and total place count

---

## Step 12 — Saved Itineraries Screen ✅

**Files updated/created:**
- `lib/screens/saved_itineraries_screen.dart`
- `lib/widgets/saved_itinerary_tile.dart`

**Features:**
- Loads all itineraries for current user on mount
- Pull-to-refresh
- Swipe-to-delete with `Dismissible` + confirm dialog
- Tap → loads itinerary into `ItineraryProvider` → navigates to `/itinerary`
- Empty state with "Plan Your First Trip" CTA
- FAB to start a new trip

---

## Step 13 — Map Screen ✅

**Files updated:**
- `lib/screens/map_screen.dart`

**Features:**
- `GoogleMap` with markers for all selected places
- Tap marker → info card appears at bottom with name, category, rating
- "Details" button on info card → navigates to place detail
- FAB opens bottom sheet list of all places — tap to fly camera to that place
- Empty state if no places selected

---

## Step 14 — Auth Screen + Home Screen ✅

**Files updated/created:**
- `lib/screens/home_screen.dart` — welcome banner with gradient, "Plan a Trip" CTA, quick action cards (My Trips / Explore Map / Login|Profile), recent 3 itineraries list
- `lib/screens/auth_screen.dart` — Login + Register tabs, password visibility toggle, error banner, guest mode
- `lib/app.dart` — added `/login` route, session restore on startup

---

## Step 15 — Polish & Tests ✅

**Analyzer fixes applied:**
- `test/widget_test.dart` — replaced stale `MyApp` reference with `TravelApp` + `MultiProvider`
- `lib/screens/auth_screen.dart` — fixed `BuildContext` across async gaps (2 instances)
- 8 files — replaced deprecated `withOpacity()` with `withValues(alpha:)`
- `docs/pubspec.yaml` — neutralized stray scaffold file that was causing asset warning

**Result:** `flutter analyze` → 0 issues

---

## Unit Tests ✅

**Files created:**
- `test/itinerary_generator_test.dart` — 13 tests covering slot assignment, rating sort, overflow distribution, duplicate prevention, empty input, `buildItinerary` correctness
- `test/model_serialization_test.dart` — 22 tests covering `User`, `Place`, `Itinerary`, `ItineraryPlace` — toJson/fromJson, toDb/fromDb, copyWith, edge cases
- `test/widget_test.dart` — smoke test that app renders home screen

**Result:** `flutter test` → 35/35 passed

---

## Remaining Before Running

1. **Add Google API key** — run with:
   ```
   flutter run --dart-define=GOOGLE_API_KEY=your_key_here
   ```
2. **Android** — add key to `android/app/src/main/AndroidManifest.xml` (see spec Section 13)
3. **iOS** — add key to `ios/Runner/AppDelegate.swift` (see spec Section 13)

---

## Enhancements

See `ENHANCEMENTS.md`. Do NOT start until core app is tested on a real device.
