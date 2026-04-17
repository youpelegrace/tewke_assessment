# Carbon Intensity Dashboard

A Flutter app for viewing live and daily carbon intensity for the Great Britain electricity grid, powered by NESO's Carbon Intensity API.

Submitted as the Tewke Flutter Technical Challenge 2026.

## Overview

The app presents:

- the current GB grid carbon intensity
- a daily chart of forecast vs actual half-hourly readings
- refresh behaviour that preserves existing data while background updates run
- a warm, sustainability-led UI with light and dark themes

## Getting Started

Requires Flutter `>=3.29.0` and Dart `>=3.10.0`.

```bash
flutter pub get
flutter run
flutter test
```

## Architecture

The codebase is lean, feature-first, and layered, but deliberately not full Clean Architecture. For a 3-4 hour brief with one screen and two endpoints, the ceremony of use cases, DI containers, and code generation would cost more than it would return.

```text
lib/
├── core/
│   ├── result.dart                         Sealed Result<T, E>
│   ├── failure.dart                        Sealed Failure hierarchy
│   └── theme/
│       ├── app_colors.dart                 Palette tokens + intensity bands
│       ├── app_theme.dart                  Light/dark ThemeData
│       └── intensity_band_theme.dart       Domain → color mapping
├── features/carbon_intensity/
│   ├── data/
│   │   ├── carbon_intensity_api.dart       Thin HTTP client, returns Result
│   │   ├── carbon_intensity_dto.dart       Transport shape + fromJson/toDomain
│   │   └── carbon_intensity_repository.dart Domain boundary
│   ├── domain/
│   │   ├── carbon_intensity.dart           Half-hour reading
│   │   └── intensity_index.dart            Pure enum, no Flutter imports
│   └── presentation/
│       ├── cubit/                          Cubit + sealed state
│       ├── pages/                          DashboardPage
│       └── widgets/                        LiveIntensityCard, DailyIntensityChart, ...
├── app.dart                                MaterialApp + DI wiring
└── main.dart
```

### Dependency Flow

```text
DashboardPage → CarbonIntensityCubit → CarbonIntensityRepository → CarbonIntensityApi → NESO
                       ↑
             observes CarbonIntensityState
```

### Key Decisions

- No use cases. The cubit depends directly on the repository because `load()` is effectively the use case. A separate use-case layer would earn its place once multiple features needed to share or compose this logic.
- No DI framework. One repository and one cubit are instantiated in `app.dart` via constructor injection. `get_it` would be useful in a larger app, but here it would mostly add noise.
- No code generation. DTOs are written by hand with `fromJson` and `toDomain`. For two response shapes, this keeps setup minimal and the code easy to read in an interview setting.
- `Result<T, Failure>` at the repository boundary instead of exceptions. The error story is explicit and every caller has to handle success and failure paths deliberately.
- Sealed state with `isRefreshing` on `Loaded`. Pull-to-refresh keeps existing data on screen instead of snapping back to a loading spinner.
- Flutter-free domain enum. `IntensityIndex` stays in pure Dart, while UI color mapping lives in `core/theme/intensity_band_theme.dart`.

## API Design

Two endpoints are used, each with a distinct responsibility:

| Endpoint | Purpose | Payload |
| --- | --- | --- |
| `GET /intensity` | Current half-hour | 1 reading |
| `GET /intensity/date` | Today in GB local day, expressed in UTC | Up to 48 half-hourly readings |

`/intensity/date` could technically supply both the live card and chart, but splitting the calls keeps the intent cleaner:

- `/intensity` is explicitly the "now" endpoint
- the live card and the chart have separate concerns
- two requests every 5 minutes is negligible relative to NESO's 30-minute settlement cadence

The API returns both forecast and actual for each half-hour. Future slots have `actual: null`, so the chart plots:

- forecast as a dashed line across the full day
- actual as a solid line ending at the latest settled half-hour

That shows both what the model expects and what the grid has actually measured.

## Reconciling Live And Daily Data

Captured payloads exposed a settlement lag between the two endpoints. At the same wall-clock time:

```text
/intensity      → 14:00Z–14:30Z actual: 77, index: low
/intensity/date → 14:00Z–14:30Z actual: null
```

NESO settles the current half-hour's actual on the live endpoint before it backfills the same slot in the bulk daily response. Left alone, that creates a temporary mismatch where the live card shows the latest measured value but the chart's last actual point is still one slot behind.

Before emitting `Loaded`, the cubit patches live `actual` into the matching daily slot with a private `_mergeLiveIntoDaily` helper. The merge is intentionally conservative:

- only fills `null` actuals
- never overwrites an existing measured value
- matches on exact UTC `from` timestamp equality
- adopts `live.index` for the patched slot, because the band should reflect the measured value

This behaviour is covered with `blocTest` cases for the happy path, no-overwrite case, no-op case, and band-adoption case.

## State Management

The app uses `flutter_bloc` with a single cubit and a sealed state model:

```text
CarbonIntensityInitial
CarbonIntensityLoading
CarbonIntensityLoaded(live, daily, lastUpdated, isRefreshing, refreshError)
CarbonIntensityError(failure)
```

Fetching is done in parallel with Dart 3 records:

```dart
(futureA, futureB).wait
```

Refresh strategy:

- explicit `load()` on cubit creation
- pull-to-refresh via `RefreshIndicator`
- periodic 5-minute timer, cancelled in `close()`

## Error Handling

Failures are surfaced at the repository boundary as sealed `Failure` subtypes:

| Failure | Trigger | UI copy |
| --- | --- | --- |
| `NetworkFailure` | `http.ClientException` | "You're offline" |
| `ServerFailure` | Non-200 status code | "The grid is napping" |
| `ParseFailure` | `FormatException`, missing data, type mismatch | "Bad data from the grid" |
| `UnknownFailure` | Anything else | "Something went wrong" |

If a refresh fails while the app is already in `Loaded`, the existing data stays visible and the failure is surfaced as a dismissible inline banner. Initial-load failures still render the dedicated error state.

## Testing

The project includes 8 test files and 41 tests covering:

- `Result`: pattern matching plus success and failure access
- `IntensityIndex`: API parsing, labels, and messaging
- DTOs: JSON shape, nullable `actual`, and UTC domain mapping
- API layer: success, 5xx, malformed JSON, missing data, network failure, and endpoint targeting via `MockClient`
- Repository: DTO-to-domain mapping and failure passthrough
- Cubit: loading, loaded, and failure paths via `bloc_test`
- `_mergeLiveIntoDaily`: patch, no-overwrite, no-op, and band-adoption cases
- Widgets: `LiveIntensityCard` and `DailyIntensityChart` rendering and edge cases

Run the suite with:

```bash
flutter test
```

## Design

The visual direction is inferred from `tewke.com`:

- Warm off-white foundation (`#F6F4EE`) with white cards, aiming closer to home/lifestyle warmth than cold tech neutrals
- Deep sage brand accent (`#2F5A3E`) as a sustainability-coded but restrained primary
- Semantic intensity bands from green through amber to coral, driven by the API's index rather than by brand
- Platform-native typography with tabular figures for the hero number
- Flat surfaces, 22px radii, and hairline borders instead of shadows
- Full dark mode using a warm charcoal base (`#141312`)

## Chart Behaviour

The chart encodes three important pieces of information through position alone:

- Hollow ring on the solid actual line: the last settled half-hour
- Dashed vertical line: true wall-clock now, using `DateTime.now().toUtc()`
- Gap between them: data staleness

Users can tap or drag to scrub the chart. The tooltip shows forecast, actual, and the half-hour range for the touched slot, which helps inspect peaks and compare forecast with reality.

## Time Handling And DST

NESO returns "today in GB local time, expressed in UTC." That matters because during BST the first slot begins at `23:00Z`, not `00:00Z`.

The naive approach:

```dart
final dayStart = DateTime.utc(now.year, now.month, now.day);
```

works during GMT but breaks during BST, causing the first hour of data to land at negative x values and pushing axis labels out of alignment.

The chart instead anchors to the first slot returned by the API:

```dart
final DateTime dayStart = data.first.from;
```

That lets the API's own day boundary define the chart, so `00:00 / 06:00 / 12:00 / 18:00 / 24:00` stay aligned to the GB day in both GMT and BST without additional timezone math. Because `c.from`, `c.to`, and `DateTime.now().toUtc()` all share the same reference frame, the duration math still works cleanly.

One side effect is intentional: a user in Tokyo still sees the GB day on a `0-24` axis instead of having the chart distorted to Tokyo midnight, which I think is the more honest presentation for GB grid data.

## Assumptions

- Tewke's exact brand palette is not public, so the sage accent is an informed inference
- the primary audience is UK-based because the API is GB-only
- times are stored in UTC and displayed using the device locale via `intl`
- a 5-minute refresh interval is sufficient given NESO's 30-minute settlement cadence

## Future Improvements

Requirements for the assessment submission, but strong next steps would be:

- regional intensity via `GET /regional/postcode/{postcode}`
- a "cleanest window" forecast card using `GET /intensity/{from}/fw24h`
- generation mix visualisation via `GET /generation`
- offline caching of the last successful response
- golden tests for the main widgets
- accessibility improvements for hero and chart semantics
- localisation via ARB message catalogs

## Credits

Carbon intensity data: NESO Carbon Intensity API, licensed CC BY 4.0.
