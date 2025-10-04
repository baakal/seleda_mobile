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

