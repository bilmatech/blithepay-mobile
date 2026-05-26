# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Setup
flutter pub get
dart run build_runner build          # Generate Hive adapters (run after model changes)

# Development
flutter run                          # Run on connected device/emulator
flutter analyze                      # Lint check
flutter format lib/                  # Format code

# Testing
flutter test                         # All tests
flutter test test/specific_test.dart # Single test file
flutter test -k "keyword"            # Tests matching keyword

# Build
flutter build apk --release
flutter build appbundle --release
flutter build ios --release
```

## Architecture

**Clean Architecture + BLoC** pattern, organized into three layers:

### Core (`lib/core/`)
Shared infrastructure all features depend on:
- **`config/`** — App config, base URL, environment flags
- **`navigation/routes.dart`** — GoRouter config; all routes defined here. Update `AppRoutes` constants when adding routes.
- **`network/`** — Dio client with interceptors (token injection, 401 refresh, error mapping), `ApiEndpoints` class
- **`storage/`** — `FlutterSecureStorage` for tokens/session; Hive for local cache
- **`theme/`** — Material 3 light/dark themes + `ThemeCubit`

### Features (`lib/features/`)
Each feature is self-contained with this internal structure:
```
feature/
  data/         # Models + repository interface & implementation
  presentation/
    bloc/        # BLoC or Cubit (events, states, handler)
    views/       # Full-screen pages
    widgets/     # Feature-scoped components
```

Key features: `auth`, `dashboard`, `students`, `fees`, `wallet`, `transaction`, `services` (utilities: airtime/data/electricity/cable/betting), `notifications`, `profile`, `recurring_payment`.

### Shared (`lib/shared/`)
Cross-feature reusable widgets only (buttons, dialogs, shimmer loaders, input fields). Never put shared widgets inside a feature folder.

## Dependency Injection

**`lib/providers.dart`** — All `RepositoryProvider` and `BlocProvider` registrations live here. Repositories are interfaces; inject via providers, never instantiate directly in UI.

## State Management

BLoC pattern: `User Action → Event → BLoC → State → UI Rebuild`

- Use `Bloc<Event, State>` for complex async logic
- Use `Cubit<State>` for simple state (e.g., theme toggle)
- All views use `BlocBuilder` / `BlocListener`; never access BLoC directly in widget trees

## API & Networking

- Base URL (staging): `https://blithepay-staging.bilma.me/api/v1/`
- All endpoints in `lib/core/network/api_endpoints.dart`
- Dio interceptor handles token refresh on 401 — modify `DioInterceptor` carefully; a bug here breaks all API calls
- `DioErrorMapper` converts network errors to domain errors; repositories return typed results

## Storage

| Store | Contents |
|-------|----------|
| `FlutterSecureStorage` | `access_token`, `refresh_token`, `expires_at`, `user` JSON |
| Hive | Local cache (minimal usage; requires `build_runner` for adapters) |

`AppLocalDataSourceImpl` exposes the current user as a `BehaviorSubject` stream — changes propagate reactively app-wide.

## Firebase

- **FCM** push notifications initialized in `main.dart` before app launch; `NotificationService` singleton manages permissions, foreground/background handling, and token sync
- Optional **Firebase Auth** for Google/Apple sign-in via `FirebaseAuthService`

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `flutter_bloc` | State management |
| `go_router` | Navigation |
| `dio` | HTTP client |
| `firebase_core`, `firebase_messaging`, `firebase_auth` | Firebase |
| `flutter_secure_storage` | Encrypted token storage |
| `hive` / `hive_flutter` | Local database |
| `shimmer` | Loading skeletons |
| `google_sign_in`, `sign_in_with_apple` | OAuth |
| `connectivity_plus` | Network state |
| `intl` | Date/number formatting |
