# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## AI Guidance

* Ignore GEMINI.md and GEMINI-*.md files
* To save main context space, for code searches, inspections, troubleshooting or analysis, use code-searcher subagent where appropriate - giving the subagent full context background for the task(s) you assign it.
* ALWAYS read and understand relevant files before proposing code edits. Do not speculate about code you have not inspected. If the user references a specific file/path, you MUST open and inspect it before explaining or proposing fixes. Be rigorous and persistent in searching code for key facts. Thoroughly review the style, conventions, and abstractions of the codebase before implementing new features or abstractions.
* After receiving tool results, carefully reflect on their quality and determine optimal next steps before proceeding. Use your thinking to plan and iterate based on this new information, and then take the best next action.
* After completing a task that involves tool use, provide a quick summary of what you've done.
* For maximum efficiency, whenever you need to perform multiple independent operations, invoke all relevant tools simultaneously rather than sequentially.
* Before you finish, please verify your solution
* Do what has been asked; nothing more, nothing less.
* NEVER create files unless they're absolutely necessary for achieving your goal.
* ALWAYS prefer editing an existing file to creating a new one.
* NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
* If you create any temporary new files, scripts, or helper files for iteration, clean up these files by removing them at the end of the task.
* When you update or modify core context files, also update markdown documentation and memory bank
* When asked to commit changes, exclude CLAUDE.md and CLAUDE-*.md referenced memory bank system files from any commits. Never delete these files.

<investigate_before_answering>
Never speculate about code you have not opened. If the user references a specific file, you MUST read the file before answering. Make sure to investigate and read relevant files BEFORE answering questions about the codebase. Never make any claims about code before investigating unless you are certain of the correct answer - give grounded and hallucination-free answers.
</investigate_before_answering>

<do_not_act_before_instructions>
Do not jump into implementatation or changes files unless clearly instructed to make changes. When the user's intent is ambiguous, default to providing information, doing research, and providing recommendations rather than taking action. Only proceed with edits, modifications, or implementations when the user explicitly requests them.
</do_not_act_before_instructions>

<use_parallel_tool_calls>
If you intend to call multiple tools and there are no dependencies between the tool calls, make all of the independent tool calls in parallel. Prioritize calling tools simultaneously whenever the actions can be done in parallel rather than sequentially. For example, when reading 3 files, run 3 tool calls in parallel to read all 3 files into context at the same time. Maximize use of parallel tool calls where possible to increase speed and efficiency. However, if some tool calls depend on previous calls to inform dependent values like the parameters, do NOT call these tools in parallel and instead call them sequentially. Never use placeholders or guess missing parameters in tool calls.
</use_parallel_tool_calls>

## Memory Bank System

This project uses a structured memory bank system with specialized context files. Always check these files for relevant information before starting work:

### Core Context Files

* **CLAUDE-activeContext.md** - Current session state, goals, and progress (if exists)
* **CLAUDE-patterns.md** - Established code patterns and conventions (if exists)
* **CLAUDE-decisions.md** - Architecture decisions and rationale (if exists)
* **CLAUDE-troubleshooting.md** - Common issues and proven solutions (if exists)
* **CLAUDE-config-variables.md** - Configuration variables reference (if exists)
* **CLAUDE-temp.md** - Temporary scratch pad (only read when referenced)

**Important:** Always reference the active context file first to understand what's currently being worked on and maintain session continuity.

### Memory Bank System Backups

When asked to backup Memory Bank System files, you will copy the core context files above and @.claude settings directory to directory @/path/to/backup-directory. If files already exist in the backup directory, you will overwrite them.

## Project Overview

Flutter mobile app — "Mini Travel Assistant" — generates daily travel itineraries using Google Places API.

- Full implementation spec: `docs/spec.md` (read before writing any code)
- Database schema: `docs/database_schema.sql`
- Sample API responses: `docs/api_examples.json`
- Enhancement roadmap: `docs/ENHANCEMENTS.md` (do not touch until core is complete)

## Architecture

Clean 3-layer architecture: **UI (screens/widgets) → Providers → Services/DB**

```
lib/
├── main.dart               # Entry point: MultiProvider setup
├── app.dart                # GoRouter configuration
├── config/                 # API key, enums (TimeSlot, PlaceCategory), Material 3 theme
├── models/                 # User, Place, Itinerary, ItineraryPlace — all @JsonSerializable
├── services/               # ApiService (Google Places REST), DatabaseHelper (SQLite singleton),
│                           # PreferencesService (SharedPreferences), mock_api_service
│   └── db/                 # DbInterface (abstract), db_sqlite.dart (mobile/desktop), db_memory.dart (web)
├── providers/              # AuthProvider, PlacesProvider, ItineraryProvider, MapProvider
├── screens/                # city_search, auth, preferences, places_list, place_detail,
│                           # itinerary, saved_itineraries, saved_itinerary_detail,
│                           # favorites, history, map, profile, account_settings, shell
├── widgets/                # Reusable components (category_chip, place_card, itinerary_tile,
│                           # time_slot_section, saved_itinerary_tile, destination_card, etc.)
└── utils/                  # itinerary_generator.dart (slot assignment algorithm), helpers.dart
```

**State management:** Provider (ChangeNotifier) — not Riverpod, not Bloc, not GetX
**Navigation:** GoRouter — not Navigator 1.0
**Database:** sqflite (mobile/desktop) + in-memory (web), abstracted via `DbInterface`
**Models:** `json_serializable` with `@JsonSerializable()` — run `build_runner` after any model change

## Bottom Nav (StatefulShellRoute — 4 branches, order is fixed)

| Index | Path | Screen |
|-------|------|--------|
| 0 | `/search` | CitySearchScreen |
| 1 | `/saved` | SavedItinerariesScreen |
| 2 | `/favorites` | FavoritesScreen |
| 3 | `/profile` | ProfileScreen |

## All Routes

**Tab routes (inside shell):** `/search`, `/saved`, `/favorites`, `/profile`, `/profile/settings`

**Non-tab routes (push on top):** `/login`, `/preferences`, `/places`, `/place/:id`, `/itinerary`, `/saved/:id`, `/history`, `/map`

> `/saved/:id` → `SavedItineraryDetailScreen` — use `int.tryParse(...) ?? -1`, never `int.parse`
> `/place/:id` — placeId is always `String`, use `?? ''` fallback not `!`

## Key Constraints

- `placeId` is a **String** (Google Place IDs like `ChIJ...`), never int
- `priceLevel` is an **int** (0–4), never string
- Store photo **references** (not full URLs); construct at runtime via `ApiService.getPhotoUrl()`
- Google API key comes from `--dart-define-from-file=.env.json` or `--dart-define=GOOGLE_API_KEY=...`, never hardcoded
- `.env.json` is gitignored — never commit it
- Use the Places API (New) endpoints; fall back to legacy Nearby Search only if needed
- Local SQLite auth only — no Firebase unless explicitly requested
- Dart SDK in this environment: **3.9.0** → `pubspec.yaml` uses `sdk: ^3.9.0`

## Favorites Feature

- Stored in `SharedPreferences` as `List<String>` under key `'favorite_ids'`
- `PreferencesService` methods: `getFavoriteIds()`, `isFavorite(id)`, `toggleFavorite(id)`
- `PlaceDetailScreen` has heart `IconButton` in `SliverAppBar` actions
- `FavoritesScreen` fetches each favorited place from DB cache by ID

## Critical Coding Patterns

- **`didChangeDependencies` + `late` field**: use a `bool _xInitialized` guard — `late final` crashes on hot reload / multiple calls
- **`mounted` checks**: always `if (!mounted) return` after every `await` before calling `setState` or `context.read`
- **Path params**: use `int.tryParse(param ?? '') ?? -1` — never `int.parse(param!)`
- **Map lookups**: null-check `Map<String, String>` values before casting to `String`
- **`capitalize(slot)`** from `utils/helpers.dart` — never `slot[0].toUpperCase()` (crashes on empty string)
- **`SavedItineraryTile.onDelete`** is optional — pass `null` for read-only lists
- **`it.id`** is `int?` — always null-guard before using `it.id!`

## Commands

```bash
# Install dependencies
flutter pub get

# Regenerate JSON serialization code (after modifying models)
dart run build_runner build

# Run app with real API (recommended)
flutter run --dart-define-from-file=.env.json

# Run app (mock API, no key needed)
flutter run

# Run unit tests (34 pass)
flutter test test/itinerary_generator_test.dart test/model_serialization_test.dart

# Run all tests
flutter test

# Static analysis
flutter analyze

# Build release APK
flutter build apk --dart-define-from-file=.env.json
```

## Testing

34 unit tests pass:
- `test/itinerary_generator_test.dart` — slot assignment algorithm (13 tests)
- `test/model_serialization_test.dart` — JSON/DB serialization for all models (22 tests)

`test/widget_test.dart` has a **pre-existing failure** — missing `ApiService` provider in test `MultiProvider` setup. Not caused by feature work; do not try to fix by changing app code.

## Memory

See `.claude/MEMORY.md` for session notes, bug fixes, and architectural decisions.
