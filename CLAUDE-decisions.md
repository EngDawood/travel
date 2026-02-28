# CLAUDE-decisions.md — Architecture Decisions & Rationale

## Navigation: 4-Tab Shell (not 3)

**Decision:** Added Favourites as a dedicated bottom nav tab (index 2), shifting Profile to index 3.

**Rationale:** `docs/app-flow.md` specifies Favorites in bottom nav. Having it as a tab gives it persistent state and matches the expected UX from the spec. Profile at index 3 is consistent with common app patterns.

**Impact:** `StatefulShellRoute` branch order in `app.dart` and `NavigationDestination` order in `shell_screen.dart` must stay in sync.

---

## Saved Itinerary Detail: Separate Screen (not reuse ItineraryScreen)

**Decision:** Created `SavedItineraryDetailScreen` at `/saved/:id` instead of reusing `ItineraryScreen` for viewing saved trips.

**Rationale:** `ItineraryScreen` is tightly coupled to `ItineraryProvider.currentItinerary` (mutable in-progress state). Reusing it for read-only saved trips caused shared state pollution. The detail screen loads directly from DB by ID with no provider dependency.

**Impact:** `SavedItinerariesScreen` now uses `context.push('/saved/${it.id}')` instead of `viewItinerary(it)` + `go('/itinerary')`.

---

## Favorites Storage: SharedPreferences (not SQLite)

**Decision:** Favorites stored as `List<String>` (place IDs) in `SharedPreferences`, not a DB table.

**Rationale:** Favorites are a lightweight user preference. Adding a DB table would require a schema migration. SharedPreferences is sufficient for a list of string IDs.

**Tradeoff:** Favorites are user-local and not tied to DB transactions. If a place is deleted from cache, the favorite ID remains but the place won't display (silently filtered in `FavoritesScreen._load()`).

---

## `didChangeDependencies` Pattern: bool Guard

**Decision:** Use `late ApiService _api` + `bool _apiInitialized = false` guard instead of `late final ApiService _api`.

**Rationale:** `late final` throws `LateInitializationError` when assigned a second time. `didChangeDependencies` is called on first build AND on every `InheritedWidget` change (including hot reload). The bool guard prevents re-assignment while keeping the field effectively final at runtime.

**Affected files:** `city_search_screen.dart`, `place_detail_screen.dart`

---

## `int.tryParse` on GoRouter Path Params

**Decision:** Always use `int.tryParse(param ?? '') ?? -1` for integer path parameters.

**Rationale:** `int.parse` throws `FormatException` on non-integer strings (deep links, corrupted nav). GoRouter builder callbacks cannot be wrapped in try/catch at the router level, so exceptions propagate as red error screens. Using `-1` as a sentinel causes the screen's `_load()` to return a "not found" error state gracefully.

---

## SDK Constraint: `^3.9.0` (not `^3.9.2`)

**Decision:** Lowered `pubspec.yaml` Dart SDK constraint from `^3.9.2` to `^3.9.0`.

**Rationale:** The IDX environment has Dart 3.9.0 installed. The original constraint prevented `flutter pub get` and `flutter analyze` from running. The app code is compatible with 3.9.0.

---

## History Screen: Read-Only (no delete)

**Decision:** `HistoryScreen` is a read-only list of all saved trips — no swipe-to-delete, no Dismissible.

**Rationale:** History implies a permanent log. Deletion is available from the Saved Itineraries screen which has the full management UI (swipe + confirmation dialog).

**Impact:** `SavedItineraryTile.onDelete` was made optional (`VoidCallback?`) to support this use case without showing a delete button.

---

## Environment: `.env.json` (not shell env vars)

**Decision:** API keys stored in `.env.json` loaded via `--dart-define-from-file=.env.json`.

**Rationale:** The file approach supports multiple keys cleanly (Google API + GitHub token). It integrates with VSCode launch configs and is gitignored. Shell env vars in `dev.nix` were removed after accidental git commit.

**Important:** `.env.json` is gitignored. Never add secrets to `dev.nix`, `launch.json`, or any tracked file.
