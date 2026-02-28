# CLAUDE-troubleshooting.md — Common Issues & Proven Solutions

## Runtime Crashes

### `LateInitializationError: Field '_api' has already been initialized`

**Cause:** `late final ApiService _api` assigned in `didChangeDependencies`, which is called multiple times.

**Fix:** Replace `late final` with `late` + bool guard:
```dart
late ApiService _api;
bool _apiInitialized = false;

@override
void didChangeDependencies() {
  super.didChangeDependencies();
  if (!_apiInitialized) {
    _api = context.read<ApiService>();
    _apiInitialized = true;
  }
}
```

**Affected:** `city_search_screen.dart`, `place_detail_screen.dart`

---

### `setState() called after dispose()`

**Cause:** Missing `mounted` check after an `await`.

**Fix:** Add `if (!mounted) return;` before every `setState` that follows an `await`.

```dart
final result = await someAsyncCall();
if (!mounted) return;   // ← add this
setState(() { ... });
```

---

### `FormatException` / red screen on `/saved/:id`

**Cause:** `int.parse(state.pathParameters['id']!)` — throws on non-integer or null.

**Fix:** `int.tryParse(state.pathParameters['id'] ?? '') ?? -1`

---

### `RangeError` in `TimeSlotSection`

**Cause:** `slot[0].toUpperCase()` on an empty string.

**Fix:** Use `capitalize(slot)` from `utils/helpers.dart`.

---

### `ProviderNotFoundException` for `ApiService` in widget test

**Cause:** `test/widget_test.dart` creates a `MultiProvider` without `ApiService`, but `CitySearchScreen` calls `context.read<ApiService>()`.

**Status:** Pre-existing issue. Do not fix by changing app code — fix by adding `Provider<ApiService>.value(value: MockApiService())` to the test's provider list.

---

## Build Issues

### `flutter pub get` fails: `SDK version ^3.9.2` mismatch

**Cause:** `pubspec.yaml` requires `^3.9.2` but IDX has Dart 3.9.0.

**Fix:** Change `sdk: ^3.9.2` → `sdk: ^3.9.0` in `pubspec.yaml`.

---

### `dart run build_runner build` needed

**Cause:** After modifying any `@JsonSerializable` model, generated `.g.dart` files become stale.

**Fix:** Run `dart run build_runner build` (or `build_runner watch` during development).

---

## Git / Secrets

### API key accidentally committed in `dev.nix`

**What happened:** `GOOGLE_API_KEY` was added to `env = {}` in `.idx/dev.nix` and committed/pushed.

**Resolution:** Removed from `dev.nix`. Key now lives only in `.env.json` (gitignored).

**Action required:** Rotate the exposed key in Google Cloud Console.

---

### `git push` fails: `could not read Username`

**Cause:** Remote URL uses HTTPS without credentials.

**Fix:** Set remote to use token in URL:
```bash
git remote set-url origin https://<TOKEN>@github.com/EngDawood/travel.git
```

---

## Navigation Issues

### Tapping saved itinerary opens wrong screen

**Old behaviour:** Tapped saved trip → `viewItinerary(it)` + `go('/itinerary')` — shared mutable provider state.

**Fixed:** Now uses `context.push('/saved/${it.id}')` → `SavedItineraryDetailScreen` loads directly from DB.

---

### Bottom nav index mismatch after adding tab

**Cause:** Adding a new `StatefulShellBranch` shifts existing branch indices. `shell_screen.dart` `NavigationDestination` list must match `app.dart` branch order exactly.

**Current order:** 0=Search, 1=Saved, 2=Favourites, 3=Profile
