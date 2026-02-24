# ENHANCEMENTS.md — Post-Core Features

> **Do NOT implement these until the core app is fully working and tested.**
> When ready, tackle them in the order listed below.

---

## Enhancement 1: Smart Scheduling (Nearest-Neighbor Route Optimization)

**Why:** The core itinerary generator just sorts by category + rating. This upgrade builds a logical travel route that minimizes walking/driving between places.

**Algorithm:** Nearest-Neighbor (greedy variant of Traveling Salesman Problem)

```
Input: List<Place> places for a given time slot, starting location (hotel or first place)
Output: Ordered list that minimizes total travel distance

1. Start at the user's current location or first selected place
2. From current position, find the nearest unvisited place (Haversine distance)
3. Move to that place, mark as visited
4. Repeat until all places are visited
5. Return the ordered list
```

**Implementation:**

File: `lib/utils/route_optimizer.dart`

```dart
class RouteOptimizer {
  /// Reorders places within a time slot to minimize total travel distance.
  /// Uses nearest-neighbor heuristic.
  static List<Place> optimize(List<Place> places, {LatLng? startFrom}) {
    // ...
  }

  /// Haversine formula — distance between two lat/lng points in km.
  static double haversineDistance(double lat1, double lng1, double lat2, double lng2) {
    // ...
  }
}
```

**Also consider:**
- Filter out places that are currently closed (using `openNow`)
- Estimate travel time between stops (~5 min per km walking, ~2 min per km driving)
- Add estimated arrival times to the itinerary display

**Changes to existing code:**
- Call `RouteOptimizer.optimize()` inside `itinerary_generator.dart` after slot assignment
- Add a "Travel time" row between places in the itinerary screen UI
- Add `estimatedArrival` field to `ItineraryPlace` model (optional, display-only)

**Report value:** You can write about the Traveling Salesman Problem, explain why exact solutions are O(n!), and justify the greedy heuristic as O(n²) and sufficient for small sets (5–10 places per slot).

---

## Enhancement 2: Preference Learning (Weighted Scoring)

**Why:** After a few trips, the app should learn what the user likes and rank those places higher.

**How it works:**
- Track user actions: save, skip, remove, view details
- Build a simple preference score per category and per price level
- Apply scores as multipliers when ranking places

**New table:**

```sql
CREATE TABLE user_actions (
    id          INTEGER PRIMARY KEY AUTOINCREMENT,
    user_id     INTEGER NOT NULL,
    place_id    TEXT NOT NULL,
    action      TEXT NOT NULL CHECK(action IN ('saved', 'skipped', 'removed', 'viewed')),
    category    TEXT NOT NULL,
    price_level INTEGER DEFAULT 0,
    created_at  TEXT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);
```

**Scoring logic:**

File: `lib/utils/preference_scorer.dart`

```dart
class PreferenceScorer {
  /// Weights for each action type
  static const actionWeights = {
    'saved': 3.0,
    'viewed': 1.0,
    'skipped': -1.0,
    'removed': -2.0,
  };

  /// Calculate preference multiplier for a place based on user history.
  /// Returns a value between 0.5 and 2.0.
  static Future<double> getScore(Place place, int userId) {
    // 1. Query user_actions for this user
    // 2. Count weighted actions per category
    // 3. Count weighted actions per price_level
    // 4. Combine into a multiplier
    // 5. Clamp between 0.5 and 2.0
  }
}
```

**Adjusted ranking formula:**
```
finalScore = place.rating × preferenceMultiplier
```

**Changes to existing code:**
- Log actions in `PlacesProvider` when user saves/skips/views
- Apply `PreferenceScorer.getScore()` in `itinerary_generator.dart` before sorting
- Add a "Recommended for you" badge on places that score > 1.5

**Report value:** You can frame this as a basic recommendation system using implicit feedback, compare it to collaborative filtering, and explain why a simpler approach fits a single-user mobile app.

---

## Enhancement 3: Offline Mode

**Why:** Travelers often lose internet in transit, underground, or abroad. Saved itineraries should work without connectivity.

**What works offline:**
- View saved itineraries (already in SQLite)
- View cached place details
- View cached map area (requires map tile caching)
- Navigate between screens

**What requires internet:**
- Search new cities
- Fetch new places
- Generate new itineraries
- View live open/closed status

**Implementation:**

### 3a. Connectivity Detection

File: `lib/services/connectivity_service.dart`

```dart
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();

  Stream<bool> get onConnectivityChanged => ...;
  Future<bool> get isOnline => ...;
}
```

### 3b. Cache Place Data Aggressively

When places are fetched from API, they're already stored in SQLite `places` table. Extend this:
- Cache place photos locally using `cached_network_image` (already in dependencies — it handles disk caching)
- Add `last_cached_at` column to `places` table to know freshness
- When offline, serve from cache; when online, refresh if `last_cached_at` > 24 hours

```sql
ALTER TABLE places ADD COLUMN last_cached_at TEXT;
```

### 3c. Offline-Aware UI

- In `PlacesProvider`, check connectivity before API calls
- If offline + cache exists → show cached data with a banner: "Showing saved data — you're offline"
- If offline + no cache → show message: "No saved data for this city. Connect to the internet to search."
- Disable "Generate New Itinerary" button when offline

### 3d. Map Tile Caching (Optional/Advanced)

Google Maps Flutter doesn't natively support offline tiles. Options:
- Use `flutter_map` + OpenStreetMap with `flutter_map_tile_caching` package (free, no API key)
- Or simply show a message "Map unavailable offline" and display the place list instead

**Recommendation:** Don't switch map libraries. Just gracefully degrade — show the list view when offline, map when online.

**Changes to existing code:**
- Add `ConnectivityService` as a provider
- Wrap API calls in `PlacesProvider` and `ItineraryProvider` with connectivity checks
- Add offline banner widget
- Add `last_cached_at` to places table and `DatabaseHelper`

**Report value:** Discuss progressive enhancement, graceful degradation, and the challenges of offline-first mobile design.

---

## Build Order for Enhancements

1. **Smart Scheduling** — most impactful, touches core algorithm, good for report
2. **Preference Learning** — adds intelligence, small scope
3. **Offline Mode** — polish feature, best done last since it touches many files

---

## Notes for Claude Code

- Each enhancement should be done on a separate branch if using git
- Write tests for `RouteOptimizer` and `PreferenceScorer` before integrating
- Don't break existing functionality — enhancements are additive
- If any enhancement conflicts with core behavior, core wins
