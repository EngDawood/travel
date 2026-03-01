# CLAUDE-patterns.md — Established Code Patterns & Conventions

## Async / State Safety

### `mounted` guard after every `await`
Always check `if (!mounted) return` before any `setState` or `context.read` that follows an `await`.

```dart
final result = await someAsyncCall();
if (!mounted) return;
setState(() { _value = result; });
```

### `late` field initialized in `didChangeDependencies`
Never use `late final` for fields set in `didChangeDependencies` — it is called multiple times (hot reload, InheritedWidget changes). Use a bool guard instead.

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

### `initState` + `addPostFrameCallback` for async loading
```dart
@override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) => _load());
}
```

### `.then()` after `context.push` needs mounted check
```dart
onTap: () => context.push('/place/$id').then((_) {
  if (mounted) _load();
}),
```

---

## Navigation (GoRouter)

### Path parameter parsing
```dart
// CORRECT — safe parse with fallback
id: int.tryParse(state.pathParameters['id'] ?? '') ?? -1,
placeId: state.pathParameters['id'] ?? '',

// WRONG — crashes on null or non-integer
id: int.parse(state.pathParameters['id']!),
placeId: state.pathParameters['id']!,
```

### Tab navigation vs push
- `context.go('/route')` — switches tabs, replaces stack
- `context.push('/route')` — pushes on top (use for non-tab detail screens)
- `context.pop()` — goes back

### Tab branch indices (must stay in sync with `shell_screen.dart`)
| Index | Path |
|-------|------|
| 0 | `/search` |
| 1 | `/saved` |
| 2 | `/favorites` |
| 3 | `/profile` |

---

## Data & Models

### placeId is always String
```dart
// CORRECT
String placeId = 'ChIJN1t_tDeuEmsRUsoyG83frY4';

// WRONG
int placeId = 123;
```

### priceLevel is always int (0–4)
```dart
// CORRECT
int priceLevel = 2;

// WRONG
String priceLevel = '$$';
```

### Photo references — store reference, build URL at runtime
```dart
// Store only the reference
place.photoReference = 'AXCi2Q...';

// Construct URL at render time
api.getPhotoUrl(place.photoReference!, maxWidth: 400)
```

---

## UI Widgets

### `capitalize(slot)` — never `slot[0].toUpperCase()`
```dart
// CORRECT — safe on empty strings, from utils/helpers.dart
capitalize(slot)

// WRONG — crashes with RangeError on empty string
'${slot[0].toUpperCase()}${slot.substring(1)}'
```

### `SavedItineraryTile.onDelete` is optional
Pass `null` for read-only lists (e.g., `HistoryScreen`). The delete button is hidden when `onDelete` is null.

### `TimeSlotSection` optional callbacks
- `onRemove` — show remove button (edit mode only)
- `onPlaceTap` — navigate to `/place/:id` on tile tap

---

## Map lookups — null-guard before cast
```dart
// CORRECT
final description = search['description'];
final placeId = search['place_id'];
if (description == null || placeId == null) return;
_onCitySelected({'description': description, 'place_id': placeId});

// WRONG — crashes if key missing
_onCitySelected({
  'description': search['description'],  // String?
  'place_id': search['place_id'],        // String? passed as String
});
```

---

## Null safety on optional model fields

### `Itinerary.id` is `int?`
Always guard before using the bang operator:
```dart
if (it.id == null) return;
// now safe to use it.id!
```

---

## Favorites (SharedPreferences)

```dart
// Storage key
static const _keyFavorites = 'favorite_ids';  // List<String>

// Usage
final ids = await _prefs.getFavoriteIds();
final isFav = await _prefs.isFavorite(placeId);
final nowFavorited = await _prefs.toggleFavorite(placeId);
```
