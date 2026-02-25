# Error Handling & Logging Design

**Date:** 2026-02-25
**Status:** Approved

## Problem

The app produces a blank white screen on any unhandled crash (e.g. widget build errors), swallows real error details in generic catch blocks, and has no logging — making it impossible to diagnose failures during development or understand what the user experienced.

## Approach: Option C — Full error boundary + structured logging

### Section 1 — Top-level error catching (`main.dart`)

Two handlers registered at app startup:

- `FlutterError.onError` — catches widget build crashes and layout errors. In debug mode logs full stack trace with `[FATAL]` prefix. Replaces blank white screen with a red error page.
- `PlatformDispatcher.instance.onError` — catches async errors that escape all try/catch blocks. Same logging behaviour.

### Section 2 — Structured logging (`lib/utils/app_logger.dart`)

A thin static utility, no external package:

```dart
AppLogger.info('[API] Fetching places for Paris');
AppLogger.warn('[DB] upsertPlaces returned 0 rows');
AppLogger.error('[Auth] Login failed', error: e, stack: stackTrace);
```

All calls wrap `debugPrint` — zero cost in release builds.

Added to: `ApiService`, `SqliteDb`, `MemoryDb`, `AuthProvider`, `PlacesProvider`, `ItineraryProvider`, `PreferencesService`.

Log prefixes:
- `[API]` — HTTP requests, responses, status codes
- `[DB]` — database init, reads, writes
- `[Auth]` — login, register, session restore
- `[Places]` — place fetching, caching
- `[Itinerary]` — generation, save, load, delete
- `[FATAL]` — uncaught errors

### Section 3 — Fix silent failures

Three critical gaps patched:

1. **`ApiService`** — add 10s timeout on all HTTP calls via `.timeout(Duration(seconds: 10))`. Log request URL and response status code on every call.
2. **`SqliteDb._initDb()`** — wrap in try/catch, rethrow with descriptive context so DB init failures surface immediately instead of hanging.
3. **Provider catch blocks** — log `e.toString()` and stack trace before setting `_error`, so real cause appears in console even when UI shows a friendly message.

### Section 4 — Specific UI error messages

Where providers expose `_error`, messages become specific by error type:

| Error type | UI message |
|---|---|
| `ApiException` | Actual API message / status code |
| `SocketException` / `TimeoutException` | "Check your internet connection" |
| DB error | "Local storage error — try restarting the app" |
| Unknown | "Something went wrong. Please try again." |

No new UI components needed — existing `_ErrorBanner` and error card widgets are already wired in auth, places, city search, place detail, and itinerary screens.

## Files Changed

| File | Change |
|---|---|
| `lib/main.dart` | Add `FlutterError.onError` + `PlatformDispatcher.instance.onError` |
| `lib/utils/app_logger.dart` | New — thin logging utility |
| `lib/services/api_service.dart` | Add timeout, log requests/responses, specific error messages |
| `lib/services/db/db_sqlite.dart` | Wrap `_initDb()` in try/catch, add logging |
| `lib/services/db/db_memory.dart` | Add logging |
| `lib/services/preferences_service.dart` | Add try/catch + logging |
| `lib/providers/auth_provider.dart` | Log real errors, specific UI messages |
| `lib/providers/places_provider.dart` | Log real errors, specific UI messages, catch DB errors |
| `lib/providers/itinerary_provider.dart` | Add error handling to `generateItinerary()`, log real errors |

## Out of Scope

- External crash reporting (Sentry, Firebase Crashlytics)
- Retry logic
- Offline mode / network connectivity detection
- Mock API error simulation
