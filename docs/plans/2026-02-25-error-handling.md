# Error Handling & Logging Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Add structured console logging and specific UI error messages throughout the app so failures are visible during development and meaningful to users.

**Architecture:** A thin `AppLogger` utility wraps `debugPrint` (zero release-build cost). Top-level `FlutterError.onError` + `PlatformDispatcher.instance.onError` handlers in `main.dart` catch unhandled crashes that currently produce a blank white screen. Services and providers log real errors before setting generic UI messages.

**Tech Stack:** Flutter built-ins only — `debugPrint`, `FlutterError`, `PlatformDispatcher`. No new packages.

---

### Task 1: Create AppLogger utility

**Files:**
- Create: `lib/utils/app_logger.dart`

**Step 1: Create the file**

```dart
// lib/utils/app_logger.dart
import 'package:flutter/foundation.dart';

/// Thin logging utility. All calls are no-ops in release builds.
/// Use prefixes: [API] [DB] [Auth] [Places] [Itinerary] [Prefs] [FATAL]
class AppLogger {
  static void info(String message) {
    debugPrint('[INFO] $message');
  }

  static void warn(String message) {
    debugPrint('[WARN] $message');
  }

  static void error(String message, {Object? error, StackTrace? stack}) {
    debugPrint('[ERROR] $message');
    if (error != null) debugPrint('  cause: $error');
    if (stack != null) debugPrint('  stack: $stack');
  }

  static void fatal(String message, {Object? error, StackTrace? stack}) {
    debugPrint('[FATAL] $message');
    if (error != null) debugPrint('  cause: $error');
    if (stack != null) debugPrint('  stack: $stack');
  }
}
```

**Step 2: Verify analysis passes**

```bash
flutter analyze lib/utils/app_logger.dart
```
Expected: no issues.

**Step 3: Commit**

```bash
git add lib/utils/app_logger.dart
git commit -m "feat: add AppLogger utility"
```

---

### Task 2: Add top-level error handlers to main.dart

**Files:**
- Modify: `lib/main.dart`

**Step 1: Replace `main()` with guarded version**

Replace the entire `lib/main.dart` with:

```dart
// lib/main.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/constants.dart';
import 'providers/auth_provider.dart';
import 'providers/places_provider.dart';
import 'providers/itinerary_provider.dart';
import 'providers/map_provider.dart';
import 'services/api_service.dart';
import 'services/mock_api_service.dart';
import 'utils/app_logger.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Catch widget build errors and layout failures (e.g. blank white screen).
  FlutterError.onError = (FlutterErrorDetails details) {
    AppLogger.fatal(
      '[FATAL] Flutter error: ${details.exceptionAsString()}',
      stack: details.stack,
    );
    FlutterError.presentError(details);
  };

  // Catch async errors that escape all try/catch blocks.
  PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
    AppLogger.fatal('[FATAL] Unhandled async error', error: error, stack: stack);
    return true; // Prevents crash on some platforms.
  };

  final ApiService apiService =
      useMockApi ? MockApiService() : ApiService(apiKey: googleApiKey);

  if (useMockApi) {
    AppLogger.warn('[App] Running in MOCK mode — no real API key detected.');
  } else {
    AppLogger.info('[App] Running with real Google Places API.');
  }

  runApp(
    MultiProvider(
      providers: [
        Provider<ApiService>.value(value: apiService),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(
            create: (ctx) => PlacesProvider(ctx.read<ApiService>())),
        ChangeNotifierProvider(create: (_) => ItineraryProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
      ],
      child: const TravelApp(),
    ),
  );
}
```

**Step 2: Verify analysis passes**

```bash
flutter analyze lib/main.dart
```
Expected: no issues.

**Step 3: Commit**

```bash
git add lib/main.dart
git commit -m "feat: add top-level FlutterError and PlatformDispatcher error handlers"
```

---

### Task 3: Add timeout and logging to ApiService

**Files:**
- Modify: `lib/services/api_service.dart`

**Step 1: Add imports at top of file**

Add after the existing imports (after line 6):

```dart
import 'dart:async';
import '../utils/app_logger.dart';
```

**Step 2: Add `_get` helper method**

Add this private helper method inside `ApiService`, before `_checkStatus` (around line 207):

```dart
  /// Performs a GET request with a 10-second timeout and logs the call.
  Future<http.Response> _get(Uri uri) async {
    AppLogger.info('[API] GET ${uri.path}${uri.query.isNotEmpty ? "?${uri.query.replaceAll(RegExp(r'key=[^&]+'), 'key=***')}" : ""}');
    try {
      final response = await http.get(uri).timeout(const Duration(seconds: 10));
      AppLogger.info('[API] ${response.statusCode} ${uri.path}');
      return response;
    } on TimeoutException {
      AppLogger.error('[API] Request timed out: ${uri.path}');
      rethrow;
    } catch (e, stack) {
      AppLogger.error('[API] Request failed: ${uri.path}', error: e, stack: stack);
      rethrow;
    }
  }
```

**Step 3: Replace `http.get(uri)` calls with `_get(uri)`**

There are 4 `http.get(uri)` calls in the file — at lines 34, 86, 119, 147.
Replace each one:

- Line 34: `final response = await http.get(uri);` → `final response = await _get(uri);`
- Line 86: `final response = await http.get(uri);` → `final response = await _get(uri);`
- Line 119: `final response = await http.get(uri);` → `final response = await _get(uri);`
- Line 147: `final response = await http.get(uri);` → `final response = await _get(uri);`

**Step 4: Verify analysis passes**

```bash
flutter analyze lib/services/api_service.dart
```
Expected: no issues.

**Step 5: Commit**

```bash
git add lib/services/api_service.dart
git commit -m "feat: add 10s timeout and request logging to ApiService"
```

---

### Task 4: Add error handling and logging to SqliteDb

**Files:**
- Modify: `lib/services/db/db_sqlite.dart`

**Step 1: Add import**

Add after line 11 (`import 'db_interface.dart';`):

```dart
import '../../utils/app_logger.dart';
```

**Step 2: Replace `_initDb()` method**

Replace lines 21–25:

```dart
  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'travel.db');
    return openDatabase(path, version: 1, onCreate: _onCreate);
  }
```

With:

```dart
  Future<Database> _initDb() async {
    try {
      AppLogger.info('[DB] Initialising SQLite database...');
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, 'travel.db');
      final db = await openDatabase(path, version: 1, onCreate: _onCreate);
      AppLogger.info('[DB] Database ready at $path');
      return db;
    } catch (e, stack) {
      AppLogger.fatal('[DB] Failed to initialise database', error: e, stack: stack);
      rethrow;
    }
  }
```

**Step 3: Verify analysis passes**

```bash
flutter analyze lib/services/db/db_sqlite.dart
```
Expected: no issues.

**Step 4: Commit**

```bash
git add lib/services/db/db_sqlite.dart
git commit -m "feat: add error handling and logging to SqliteDb initialisation"
```

---

### Task 5: Add logging to InMemoryDb

**Files:**
- Modify: `lib/services/db/db_memory.dart`

**Step 1: Add import**

Add after line 9 (`import 'db_interface.dart';`):

```dart
import '../../utils/app_logger.dart';
```

**Step 2: Add log line to `insertUser`**

In `insertUser` (around line 24), add before the `return id;` line:

```dart
    AppLogger.info('[DB] InMemoryDb: inserted user id=$id email=${user.email}');
```

**Step 3: Add log line to `insertItinerary`**

In `insertItinerary` (around line 87), add before `return id;`:

```dart
    AppLogger.info('[DB] InMemoryDb: inserted itinerary id=$id city=${itinerary.city}');
```

**Step 4: Verify analysis passes**

```bash
flutter analyze lib/services/db/db_memory.dart
```
Expected: no issues.

**Step 5: Commit**

```bash
git add lib/services/db/db_memory.dart
git commit -m "feat: add logging to InMemoryDb"
```

---

### Task 6: Add try/catch and logging to PreferencesService

**Files:**
- Modify: `lib/services/preferences_service.dart`

**Step 1: Add import**

Add after line 2 (`import 'package:shared_preferences/shared_preferences.dart';`):

```dart
import '../utils/app_logger.dart';
```

**Step 2: Replace entire file body**

Replace the three methods with guarded versions:

```dart
  /// Save the logged-in user id.
  Future<void> saveUserId(int id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyUserId, id);
      AppLogger.info('[Prefs] Saved userId=$id');
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to save userId', error: e, stack: stack);
      rethrow;
    }
  }

  /// Get the logged-in user id, or null if not logged in.
  Future<int?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_keyUserId);
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to read userId', error: e, stack: stack);
      return null;
    }
  }

  /// Clear session (logout).
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyUserId);
      AppLogger.info('[Prefs] Session cleared');
    } catch (e, stack) {
      AppLogger.error('[Prefs] Failed to clear session', error: e, stack: stack);
    }
  }
```

**Step 3: Verify analysis passes**

```bash
flutter analyze lib/services/preferences_service.dart
```
Expected: no issues.

**Step 4: Commit**

```bash
git add lib/services/preferences_service.dart
git commit -m "feat: add try/catch and logging to PreferencesService"
```

---

### Task 7: Add logging and specific error messages to AuthProvider

**Files:**
- Modify: `lib/providers/auth_provider.dart`

**Step 1: Add imports**

Add after line 4 (`import 'package:flutter/foundation.dart';`):

```dart
import 'dart:async';
import '../utils/app_logger.dart';
```

**Step 2: Replace `restoreSession()`**

Replace lines 24–30:

```dart
  Future<void> restoreSession() async {
    final userId = await _prefs.getUserId();
    if (userId != null) {
      _currentUser = await _db.getUserById(userId);
      notifyListeners();
    }
  }
```

With:

```dart
  Future<void> restoreSession() async {
    try {
      final userId = await _prefs.getUserId();
      if (userId != null) {
        AppLogger.info('[Auth] Restoring session for userId=$userId');
        _currentUser = await _db.getUserById(userId);
        AppLogger.info('[Auth] Session restored: ${_currentUser?.email ?? "user not found"}');
      }
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('[Auth] Failed to restore session', error: e, stack: stack);
      // Non-fatal: user will just see login screen.
    }
  }
```

**Step 3: Replace `register()` catch block**

Replace lines 55–57:

```dart
    } catch (e) {
      _error = 'Registration failed. Please try again.';
      return false;
```

With:

```dart
    } catch (e, stack) {
      AppLogger.error('[Auth] Registration failed', error: e, stack: stack);
      _error = _dbErrorMessage(e);
      return false;
```

**Step 4: Replace `login()` catch block**

Replace lines 83–85:

```dart
    } catch (e) {
      _error = 'Login failed. Please try again.';
      return false;
```

With:

```dart
    } catch (e, stack) {
      AppLogger.error('[Auth] Login failed', error: e, stack: stack);
      _error = _dbErrorMessage(e);
      return false;
```

**Step 5: Replace `updatePreferences()` with guarded version**

Replace lines 99–104:

```dart
  Future<void> updatePreferences(List<String> categories) async {
    if (_currentUser == null) return;
    await _db.updateUserCategories(_currentUser!.id!, categories);
    _currentUser = _currentUser!.copyWith(preferredCategories: categories);
    notifyListeners();
  }
```

With:

```dart
  Future<void> updatePreferences(List<String> categories) async {
    if (_currentUser == null) return;
    try {
      await _db.updateUserCategories(_currentUser!.id!, categories);
      _currentUser = _currentUser!.copyWith(preferredCategories: categories);
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('[Auth] Failed to update preferences', error: e, stack: stack);
    }
  }
```

**Step 6: Add `_dbErrorMessage` helper at the bottom of the class** (before the closing `}`)

```dart
  String _dbErrorMessage(Object e) {
    if (e is TimeoutException) return 'Request timed out. Please try again.';
    return 'Local storage error. Try restarting the app.';
  }
```

**Step 7: Verify analysis passes**

```bash
flutter analyze lib/providers/auth_provider.dart
```
Expected: no issues.

**Step 8: Commit**

```bash
git add lib/providers/auth_provider.dart
git commit -m "feat: add logging and specific error messages to AuthProvider"
```

---

### Task 8: Add logging, DB error catch, and specific messages to PlacesProvider

**Files:**
- Modify: `lib/providers/places_provider.dart`

**Step 1: Add imports**

Add after line 2 (`import 'package:flutter/foundation.dart';`):

```dart
import 'dart:async';
import '../utils/app_logger.dart';
```

**Step 2: Replace `fetchPlaces()` method**

Replace lines 44–63:

```dart
  Future<void> fetchPlaces(List<PlaceCategory> categories) async {
    _setLoading(true);
    _error = null;
    try {
      final places = await _api.searchNearbyMultiple(
        lat: _cityLat,
        lng: _cityLng,
        categories: categories,
      );
      // Cache to SQLite
      await _db.upsertPlaces(places);
      _fetchedPlaces = places;
    } on ApiException catch (e) {
      _error = e.message;
    } catch (e) {
      _error = 'Failed to fetch places. Please try again.';
    } finally {
      _setLoading(false);
    }
  }
```

With:

```dart
  Future<void> fetchPlaces(List<PlaceCategory> categories) async {
    _setLoading(true);
    _error = null;
    AppLogger.info('[Places] Fetching ${categories.length} category(ies) near $_currentCity');
    try {
      final places = await _api.searchNearbyMultiple(
        lat: _cityLat,
        lng: _cityLng,
        categories: categories,
      );
      AppLogger.info('[Places] Fetched ${places.length} places');
      try {
        await _db.upsertPlaces(places);
      } catch (dbErr, dbStack) {
        AppLogger.warn('[Places] DB cache failed (non-fatal): $dbErr');
        AppLogger.error('[Places] DB cache stack', error: dbErr, stack: dbStack);
      }
      _fetchedPlaces = places;
    } on ApiException catch (e, stack) {
      AppLogger.error('[Places] API error', error: e, stack: stack);
      _error = e.message;
    } on TimeoutException catch (e, stack) {
      AppLogger.error('[Places] Timeout', error: e, stack: stack);
      _error = 'Request timed out. Check your connection.';
    } catch (e, stack) {
      AppLogger.error('[Places] Unexpected error', error: e, stack: stack);
      _error = 'Failed to fetch places. Please try again.';
    } finally {
      _setLoading(false);
    }
  }
```

**Step 3: Verify analysis passes**

```bash
flutter analyze lib/providers/places_provider.dart
```
Expected: no issues.

**Step 4: Commit**

```bash
git add lib/providers/places_provider.dart
git commit -m "feat: add logging, DB error isolation, and specific messages to PlacesProvider"
```

---

### Task 9: Add error handling and logging to ItineraryProvider

**Files:**
- Modify: `lib/providers/itinerary_provider.dart`

**Step 1: Add imports**

Add after line 2 (`import 'package:flutter/foundation.dart';`):

```dart
import '../utils/app_logger.dart';
```

**Step 2: Replace `generateItinerary()` with guarded version**

Replace lines 23–36:

```dart
  void generateItinerary({
    required List<Place> selectedPlaces,
    required String city,
    required int userId,
  }) {
    final slotMap = ItineraryGenerator.generate(selectedPlaces);
    _currentItinerary = ItineraryGenerator.buildItinerary(
      slotMap: slotMap,
      city: city,
      userId: userId,
    );
    notifyListeners();
  }
```

With:

```dart
  void generateItinerary({
    required List<Place> selectedPlaces,
    required String city,
    required int userId,
  }) {
    _error = null;
    try {
      AppLogger.info('[Itinerary] Generating for $city with ${selectedPlaces.length} places');
      final slotMap = ItineraryGenerator.generate(selectedPlaces);
      _currentItinerary = ItineraryGenerator.buildItinerary(
        slotMap: slotMap,
        city: city,
        userId: userId,
      );
      AppLogger.info('[Itinerary] Generated: ${_currentItinerary?.places.length ?? 0} slots');
      notifyListeners();
    } catch (e, stack) {
      AppLogger.error('[Itinerary] Generation failed', error: e, stack: stack);
      _error = 'Failed to generate itinerary. Please try again.';
      notifyListeners();
    }
  }
```

**Step 3: Add logging to remaining catch blocks**

In `saveItinerary()`, replace line 50:
```dart
      _error = 'Failed to save itinerary.';
```
With:
```dart
      AppLogger.error('[Itinerary] Failed to save', error: e);
      _error = 'Local storage error. Try restarting the app.';
```

In `loadSaved()`, replace line 64:
```dart
      _error = 'Failed to load saved itineraries.';
```
With:
```dart
      AppLogger.error('[Itinerary] Failed to load saved', error: e);
      _error = 'Local storage error. Try restarting the app.';
```

In `deleteItinerary()`, replace line 77:
```dart
      _error = 'Failed to delete itinerary.';
```
With:
```dart
      AppLogger.error('[Itinerary] Failed to delete id=$id', error: e);
      _error = 'Local storage error. Try restarting the app.';
```

In `renameItinerary()`, replace line 92:
```dart
      _error = 'Failed to rename itinerary.';
```
With:
```dart
      AppLogger.error('[Itinerary] Failed to rename id=$id', error: e);
      _error = 'Local storage error. Try restarting the app.';
```

Note: The `catch (e)` blocks in those methods need `(e, stack)` if you want stack traces. Update them:
- `saveItinerary` line 49: `} catch (e) {` → `} catch (e, stack) {`  (then pass `stack:` to AppLogger)
- `loadSaved` line 63: same
- `deleteItinerary` line 76: same
- `renameItinerary` line 91: same

**Step 4: Verify analysis passes**

```bash
flutter analyze lib/providers/itinerary_provider.dart
```
Expected: no issues.

**Step 5: Commit**

```bash
git add lib/providers/itinerary_provider.dart
git commit -m "feat: add error handling and logging to ItineraryProvider"
```

---

### Task 10: Final verification

**Step 1: Run all tests**

```bash
flutter test
```
Expected: all 35 tests pass.

**Step 2: Run full analysis**

```bash
flutter analyze
```
Expected: no issues.

**Step 3: Run app in mock mode (no key needed) and check console**

```bash
flutter run -d chrome
```
Expected console output:
```
[WARN] [App] Running in MOCK mode — no real API key detected.
```

**Step 4: Run app with real API key and check console**

```bash
flutter run -d chrome --dart-define-from-file=.env.json
```
Expected console output includes:
```
[INFO] [App] Running with real Google Places API.
[INFO] [DB] Initialising SQLite database...   ← only on mobile/desktop
```
When searching a city:
```
[INFO] [API] GET /maps/api/place/autocomplete/json?...key=***
[INFO] [API] 200 /maps/api/place/autocomplete/json
[INFO] [Places] Fetching 3 category(ies) near Paris
[INFO] [API] GET /maps/api/place/nearbysearch/json?...
[INFO] [Places] Fetched 42 places
```

**Step 5: Commit if any fixes were needed**

```bash
git add -A
git commit -m "fix: final analysis and test fixes for error handling"
```
