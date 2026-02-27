# Project Memory — Mini Travel Assistant

## Architecture
- **3-layer**: UI (screens/widgets) → Providers → Services/DB
- **State**: Provider (ChangeNotifier) — not Riverpod, not Bloc
- **Nav**: GoRouter with `StatefulShellRoute.indexedStack` (4 tabs)
- **DB**: sqflite (mobile) / in-memory (web) via `DbInterface` abstraction
- **Models**: `@JsonSerializable` — run `dart run build_runner build` after model changes

## Bottom Nav Tabs (order matters for branch index)
| Index | Path | Screen |
|-------|------|--------|
| 0 | `/search` | CitySearchScreen |
| 1 | `/saved` | SavedItinerariesScreen |
| 2 | `/favorites` | FavoritesScreen |
| 3 | `/profile` | ProfileScreen |

## Non-Tab Routes
- `/login` — AuthScreen
- `/preferences` — PreferencesScreen
- `/places` — PlacesListScreen
- `/place/:id` — PlaceDetailScreen (placeId is String, never int)
- `/itinerary` — ItineraryScreen (current in-progress itinerary)
- `/saved/:id` — SavedItineraryDetailScreen (id parsed with int.tryParse)
- `/history` — HistoryScreen (read-only trip log)
- `/map` — MapScreen
- `/profile/settings` — AccountSettingsScreen

## Key Constraints
- `placeId` is **String** (Google Place IDs like `ChIJ...`), never int
- `priceLevel` is **int** (0–4), never string
- Store photo **references** (not full URLs); construct via `ApiService.getPhotoUrl()`
- API key via `--dart-define=GOOGLE_API_KEY=...` or `--dart-define-from-file=.env.json`
- `.env.json` is gitignored — never commit it
- Local SQLite auth only — no Firebase

## Favorites
- Stored in `SharedPreferences` as a string list under key `'favorite_ids'`
- `PreferencesService`: `getFavoriteIds()`, `isFavorite()`, `toggleFavorite()`
- Heart icon in `PlaceDetailScreen` SliverAppBar actions
- `FavoritesScreen` loads IDs → fetches each Place from DB cache

## Patterns & Bugs Fixed
- `didChangeDependencies` with `late final` field → use `late` + bool `_initialized` guard
- Always `if (!mounted) return` after every `await` before calling `setState`
- `int.tryParse(...) ?? -1` (never `int.parse`) on GoRouter path params
- `capitalize(slot)` (not `slot[0].toUpperCase()`) — safe on empty strings
- Null-guard `Map<String, String>` lookups before casting to `String`
- `SavedItineraryTile.onDelete` is optional — pass `null` for read-only lists
- Guard `it.id == null` before using `it.id!` in delete flows

## Environment / SDK
- Dart SDK in IDX: **3.9.0** → `pubspec.yaml` constraint set to `^3.9.0`
- Flutter: 3.35.2
- Run with real API: `flutter run --dart-define-from-file=.env.json`
- Run mock: `flutter run`

## Tests
- 34 unit tests pass: `itinerary_generator_test.dart` (13) + `model_serialization_test.dart` (22) - run with `flutter test test/itinerary_generator_test.dart test/model_serialization_test.dart`
- `widget_test.dart` has pre-existing failure: missing `ApiService` provider in test setup (not caused by our changes)

## Git Remote
- `https://ghp_<token>@github.com/EngDawood/travel.git` (token stored in `.env.json`, not in code)
- Branch: `master`
