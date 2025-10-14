# Seleda Finance

Seleda Finance is a personal finance MVP built with Flutter using strict Clean Architecture boundaries.

## Features
- Add income and expense transactions with optional receipt attachments
- Dashboard with running balance and recent entries
- Offline-first with local Drift (SQLite) persistence
- Voice-to-text prefill for transaction forms
- Riverpod state management and Material 3 UI

## Getting Started

### Prerequisites
- [Flutter](https://flutter.dev/docs/get-started/install) (stable, Dart 3.x)
- Android/iOS tooling for your target platform

### Install dependencies
```bash
flutter pub get
```

### Generate Drift database code
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Run the app
```bash
flutter run
```

### Run tests
```bash
flutter test
```

## Project Structure
```
lib/
  app/              # router, theme, dependency injection
  core/             # cross-cutting utilities (Result, Failure)
  features/
    transactions/   # feature modules broken into presentation, application, domain, infrastructure, external
  shared/           # shared widgets/formatters
```

## Code Generation
Drift uses build_runner to generate SQL bindings. Re-run `dart run build_runner build --delete-conflicting-outputs` whenever you modify Drift table definitions.

## Permissions
- **Android**: update `android/app/src/main/AndroidManifest.xml` with camera, storage, and microphone permissions.
- **iOS**: add `NSCameraUsageDescription`, `NSPhotoLibraryAddUsageDescription`, and `NSMicrophoneUsageDescription` to `Info.plist`.

If permissions are denied, the voice and image features gracefully degrade.

## Debug Seed Data
`AppDatabase` seeds three sample transactions the first time it is opened in debug builds to help during development. Remove or adjust this as needed.

## Scripts
Common tasks:
- `flutter pub get`
- `dart run build_runner build --delete-conflicting-outputs`
- `flutter test`
- `flutter run`

## Troubleshooting
- If Drift code generation fails, ensure no editor is locking files and rerun build_runner.
- For voice-to-text to work on simulators, ensure microphone access is enabled.

## UI Redesign (Prototype Integration)

The folder `seleda-flutter-restructure/` contained an earlier UI prototype (GetX-based) with:
- Splash screen
- Bottom navigation (Home, Category, Search, Excel, Settings)
- Reports / Charts page
- Settings & Account pages with dark mode toggle

This repository now integrates modern equivalents using Riverpod + GoRouter:

Implemented additions:
1. ShellRoute + `NavigationBar` bottom navigation (Home, Transactions, Reports, Settings)
2. `ReportPage` with basic time–range filtering (week/month/year) and line chart (Syncfusion)
3. `SettingsPage` with dark mode toggle (Riverpod `themeModeProvider`) and account stub
4. `AccountPage` stub with language chip placeholders
5. `SplashPage` (initial route) that transitions to dashboard
6. Theme mode state via `ThemeModeNotifier`

New dependencies (run `flutter pub get`):
- syncfusion_flutter_charts
- flutter_spinkit
- dropdown_button2 (reserved for future enhanced dropdown UX)

Planned / Deferred:
- Search integration (transaction search + suggestion UI)
- Localization (Amharic, Tigrigna, Oromiffa) using ARB / intl
- Export to Excel (prototype icon placeholder only)
- Advanced report visuals (stacked bars, category breakdown, pie chart)
- Authentication & real user profile

### Next Steps Suggested
- Add repository layer aggregations for performance (pre-compute weekly/monthly sums)
- Introduce a `SearchController` with debounced query stream
- Add `intl` localization setup and move hard-coded strings into messages
- Write widget tests for new pages (report filtering, theme toggle persistence)
- Persist theme preference locally (e.g., `SharedPreferences` / `Hive`)


