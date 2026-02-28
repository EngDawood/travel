# CLAUDE-config-variables.md — Configuration Variables Reference

## Environment / Dart Defines

| Variable | Source | Description |
|----------|--------|-------------|
| `GOOGLE_API_KEY` | `.env.json` | Google Places API key — passed via `--dart-define-from-file=.env.json` |
| `GITHUB_PERSONAL_ACCESS_TOKEN` | `.env.json` | GitHub PAT for pushing — used in git remote URL |

**Never hardcode these.** `.env.json` is gitignored.

## Runtime Constants (`lib/config/constants.dart`)

| Constant | Value | Description |
|----------|-------|-------------|
| `googleApiKey` | `String.fromEnvironment('GOOGLE_API_KEY', defaultValue: '')` | Resolved at compile time from dart-define |
| `useMockApi` | `googleApiKey.isEmpty` | Automatically true when no key provided |
| `placesBaseUrl` | `'https://maps.googleapis.com/maps/api/place'` | Google Places API base URL |
| `maxPlacesPerSlot` | `3` | Max places per time slot in generated itinerary |
| `nearbySearchRadius` | `5000` | Nearby search radius in metres |

## SharedPreferences Keys (`lib/services/preferences_service.dart`)

| Key | Type | Description |
|-----|------|-------------|
| `'user_id'` | `int` | Logged-in user's local DB id |
| `'recent_searches'` | `String` (JSON) | List of `{description, place_id}` maps, max 10 |
| `'favorite_ids'` | `List<String>` | Place IDs the user has hearted |

## Enums (`lib/config/constants.dart`)

### `TimeSlot`
| Value | Label | Display |
|-------|-------|---------|
| `morning` | `'morning'` | 8:00 AM – 12:00 PM |
| `afternoon` | `'afternoon'` | 12:00 PM – 5:00 PM |
| `evening` | `'evening'` | 5:00 PM – 10:00 PM |

### `PlaceCategory`
| Value | Google Types |
|-------|-------------|
| `restaurant` | `['restaurant']` |
| `cafe` | `['cafe']` |
| `attraction` | `['tourist_attraction', 'museum', 'park']` |
| `shopping` | `['shopping_mall', 'store']` |
| `nightlife` | `['bar', 'night_club']` |

## GoRouter Named Routes

| Name | Path | Screen |
|------|------|--------|
| `citySearch` | `/search` | CitySearchScreen |
| `saved` | `/saved` | SavedItinerariesScreen |
| `favorites` | `/favorites` | FavoritesScreen |
| `profile` | `/profile` | ProfileScreen |
| `accountSettings` | `/profile/settings` | AccountSettingsScreen |
| `login` | `/login` | AuthScreen |
| `preferences` | `/preferences` | PreferencesScreen |
| `places` | `/places` | PlacesListScreen |
| `placeDetail` | `/place/:id` | PlaceDetailScreen |
| `itinerary` | `/itinerary` | ItineraryScreen |
| `savedDetail` | `/saved/:id` | SavedItineraryDetailScreen |
| `history` | `/history` | HistoryScreen |
| `map` | `/map` | MapScreen |

## Flutter / Dart SDK

| Item | Value |
|------|-------|
| Flutter | 3.35.2 |
| Dart SDK (IDX) | 3.9.0 |
| `pubspec.yaml` constraint | `sdk: ^3.9.0` |
| Android target | API 36 (emulator) |
