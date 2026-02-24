# CLAUDE.md — Mini Travel Assistant

## Project Context

This is a **Flutter mobile app** called "Mini Travel Assistant" — a final year CS project for Applied Science University (Bahrain). It helps travelers generate organized daily itineraries using Google Places API.

**Student:** Abdulrahman Qasem Ali (ID: 20227110129)

## Key Files

- `spec.md` — Full implementation spec. **Read this first before writing any code.**
- `pubspec.yaml` — Dependencies are pre-configured. Do not change versions.
- `database_schema.sql` — SQLite schema. Follow exactly.
- `api_examples.json` — Sample Google Places API responses for reference when building parsers.
- `.env.example` — Required environment variables.
- `ENHANCEMENTS.md` — Post-core features (smart scheduling, preference learning, offline mode). **Do NOT touch until core is complete and tested.**

## Rules

### Must Follow
- **Read `spec.md` fully** before starting implementation.
- Follow the **project structure** defined in spec.md Section 4 exactly.
- Follow the **build order** in spec.md Section 14.
- Use **Provider** for state management — not Riverpod, not Bloc, not GetX.
- Use **GoRouter** for navigation — not Navigator 1.0.
- Use **sqflite** for local database — not Hive, not Isar, not drift.
- PlaceID is a **String** (Google Place IDs look like `ChIJ...`), never int.
- PriceLevel is an **int** (0–4), never string.
- Store Google photo **references** (not full URLs) — construct URLs at runtime via `APIService.getPhotoUrl()`.
- All models must use `json_serializable` with `@JsonSerializable()` annotations.
- Run `dart run build_runner build` after creating/modifying models.

### Don't Do
- Don't add Firebase Auth unless explicitly asked — use local SQLite auth for now.
- Don't use any AI/ML libraries.
- Don't hardcode the Google API key in source files — read from `--dart-define` or constants file.
- Don't use deprecated Google Places API endpoints — use the current Places API (New) where possible, fall back to legacy Nearby Search if needed.
- Don't create unnecessary abstractions or over-engineer. Keep it simple and working.

## Code Style
- Use `lowerCamelCase` for variables and methods.
- Use `UpperCamelCase` for classes.
- Use `snake_case` for file names.
- Keep widgets extracted into `lib/widgets/` when reusable.
- Every screen gets its own file in `lib/screens/`.
- Every provider gets its own file in `lib/providers/`.
- Add brief doc comments to public methods in services.

## Testing
- Write unit tests for `itinerary_generator.dart` (core algorithm).
- Write unit tests for model serialization (fromJson / toJson).
- Widget tests are optional but appreciated.

## When in Doubt
- Refer back to `spec.md`.
- If something in the spec is ambiguous, choose the simpler approach.
- If a Google API endpoint is unclear, check `api_examples.json` for the expected response shape.
