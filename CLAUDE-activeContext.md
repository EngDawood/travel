# CLAUDE-activeContext.md — Current Session State

## Status: Session Complete ✓

## What Was Done This Session

### Features Implemented
1. **FavoritesScreen** (`/favorites`) — heart-toggled places from SharedPreferences
2. **SavedItineraryDetailScreen** (`/saved/:id`) — read-only detail loaded from DB by ID
3. **HistoryScreen** (`/history`) — read-only trip log, accessible from Profile
4. **Heart toggle** in `PlaceDetailScreen` SliverAppBar
5. **4th bottom nav tab** (Favourites at index 2, Profile moved to index 3)
6. **Profile menu wired**: Favorites → `/favorites`, History → `/history`
7. **Saved itineraries tap** now pushes `/saved/:id` instead of shared provider state

### Bugs Fixed
- `LateInitializationError` in `city_search_screen.dart` and `place_detail_screen.dart`
- Missing `mounted` guards in `place_detail_screen.dart`, `favorites_screen.dart`, `city_search_screen.dart`
- `int.parse` → `int.tryParse` on GoRouter path params
- Null-bang `!` → `?? ''` fallback on place detail path param
- Null-guard on `it.id` before delete operations
- `slot[0].toUpperCase()` → `capitalize(slot)` in `TimeSlotSection`
- Null-guard on `Map<String, String>` lookups in `_onRecentSearchTap`

### Config Changes
- `.env.json` created (gitignored) with `GOOGLE_API_KEY` and `GITHUB_PERSONAL_ACCESS_TOKEN`
- `dev.nix` cleaned — API key removed after accidental commit
- `pubspec.yaml` SDK constraint lowered to `^3.9.0`
- `CLAUDE.md` updated with current routes, patterns, constraints
- Memory bank files created

## Current State of Codebase
- `flutter analyze` — **0 issues**
- Unit tests — **34/34 pass**
- Widget smoke test — pre-existing failure (missing ApiService in test provider setup)
- Git branch: `master` — up to date with `origin/master`

## Next Steps (not started)
- See `docs/ENHANCEMENTS.md` for roadmap (do not touch until core confirmed complete)
- Fix widget test by adding `MockApiService` to test provider setup
