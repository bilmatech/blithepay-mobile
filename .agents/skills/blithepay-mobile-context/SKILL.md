---
name: blithepay-mobile-context
description: >
  Provides architectural context, coding conventions, and key patterns for the
  BlithePay mobile Flutter project. Activate whenever working in this workspace
  to ensure changes align with established patterns.
---

# BlithePay Mobile — Project Context

## Overview

**BlithePay** is a Flutter mobile app for school fee management targeted at guardians/parents.
It lets users link students to schools, view and pay fee invoices, manage a wallet, and use VAS utilities (airtime, data, electricity, cable TV, betting).

- **App name in code**: `blithepay` (package name)
- **Version**: 1.0.1+1
- **Dart SDK**: `^3.10.1`
- **Flutter**: 3.x (Material 3)

---

## Architecture: Clean Architecture + BLoC

Three strict layers:

```
lib/
├── core/          # Shared infrastructure (no feature-specific logic)
├── features/      # Self-contained feature modules
└── shared/        # Cross-feature reusable widgets ONLY
```

### Core Layer (`lib/core/`)

| Directory       | Purpose |
|-----------------|---------|
| `config/`       | `Env` class with base URLs |
| `constants/`    | `AppColors`, `AppTextStyles`, `AppTypography`, `AppSpacing`, `AppStrings` |
| `navigation/`   | GoRouter config (`routes.dart`), route name constants (`app_routes.dart`), barrel (`index.dart`) |
| `network/`      | `DioClient`, `DioInterceptor`, `ApiEndpoints`, `DioErrorMapper`, `NetworkExceptions`, `ServerResponse`, `IdempotencyKeyFactory` |
| `storage/`      | `AppLocalDataSource` (abstract) + `AppLocalDataSourceImpl` (FlutterSecureStorage + BehaviorSubject) |
| `theme/`        | `buildLightTheme()`, `buildDarkTheme()`, `ThemeCubit`, `ThemeState` |
| `services/`     | `NotificationService` (FCM + local), `FirebaseAuthService` |
| `utils/`        | Validators, helpers, extensions |
| `localization/` | i18n/l10n support |

### Feature Layer (`lib/features/`)

Each feature follows this exact internal structure (no exceptions):
```
feature/
  data/
    models/        # Data models (fromJson/toJson)
    repositories/  # Abstract interface + concrete implementation
  presentation/
    bloc/          # BLoC or Cubit (events, states, handler)
    views/         # Full-screen pages
    widgets/       # Feature-scoped components only
```

**Active features**: `auth`, `dashboard`, `students`, `fees`, `wallet`, `transaction`,
`vas` (sub-features: `airtime`, `data_bundle`, `cable_tv`, `electricity`, `bettings`),
`notifications`, `profile`, `recurring_payment`, `schools`, `splash`, `support`, `common`.

### Shared Layer (`lib/shared/`)

- `shared/widgets/` — reusable UI components used across features
- Sub-directories: `buttons/`, `inputs/`, `cards/`, `dialogs/`, `bottom_sheets/`, `loaders/`, `layouts/`, `background/`
- `shared/layouts/` — layout scaffolds

> **Rule**: Never put a shared widget inside a feature folder. Never put feature-specific logic in `shared/`.

---

## Dependency Injection (`lib/providers.dart`)

`AppProviders` class with two static methods:
- `AppProviders.repositories()` → `List<RepositoryProvider>` (registered in `MultiRepositoryProvider`)
- `AppProviders.blocs()` → `List<BlocProvider>` (registered in `MultiBlocProvider`)

**Pattern**: Repositories are interfaces; always inject via `context.read<Interface>()`, never
instantiate directly in UI. Concrete implementations are registered against their abstract interface type.

Key provider chain (instantiation order matters):
1. `FlutterSecureStorage` → const
2. `AppLocalDataSourceImpl(secureStorage)`
3. `DioClient(authLocalDataSource)`
4. Feature repositories using `DioClient`
5. Feature BLoCs using their repository

When adding a new feature: register both the repository (`RepositoryProvider`) and its BLoC
(`BlocProvider`) in `providers.dart`.

---

## State Management (BLoC Pattern)

`User Action → Event → BLoC → State → UI Rebuild`

- Use `Bloc<Event, State>` for complex async logic
- Use `Cubit<State>` for simple state (e.g., `ThemeCubit`)
- All views use `BlocBuilder` / `BlocListener` / `BlocConsumer`
- Never access BLoC directly in widget trees — always `context.read<>()` or `context.watch<>()`
- BLoC event classes extend the feature's base event class
- States use `Equatable` for value comparison

---

## Networking

- **Production base URL**: `https://apis.blithepay.com/api/` + version `v1` → defined in `Env` class
- **Staging base URL**: `https://blithepay-staging.bilma.me/api/` (commented out in `env.dart`)
- All endpoints are static constants/methods in `ApiEndpoints` class (`lib/core/network/api_endpoints.dart`)
- `DioInterceptor` handles:
  - Token injection (`Authorization: Bearer <token>`)
  - Proactive token refresh (10 seconds before expiry)
  - 401 retry with token refresh
  - Request queue management for concurrent requests during refresh
  - Force-logout on refresh failure (clears session, navigates to `/login`)
- `DioErrorMapper` converts Dio errors to domain errors
- `IdempotencyKeyFactory` uses SHA-256 hash of `invoiceId + sorted feeItemIds` as cache key,
  UUID v4 as the actual idempotency key — used for fee payment operations to prevent duplicates

> **Caution**: Modify `DioInterceptor` very carefully — a bug here breaks all API calls.

---

## Storage

| Store | Keys / Contents |
|-------|----------------|
| `FlutterSecureStorage` | `access_token`, `refresh_token`, `expires_at`, `user` (JSON) |
| `FlutterSecureStorage` | `onboarding_completed` (bool as string `'true'`) |
| Hive | Local cache (minimal usage; requires `build_runner` for adapters) |

`AppLocalDataSourceImpl` exposes `userStream` as `Stream<UserModel?>` via
`BehaviorSubject<AuthResponseModel?>` — changes propagate reactively app-wide.

---

## Navigation (GoRouter)

- Route name constants: `AppRoutes` abstract class in `lib/core/navigation/app_routes.dart`
- Full GoRouter config: `lib/core/navigation/routes.dart`
- All navigation uses `context.go()` / `context.push()` / `context.pop()` (GoRouter API)
- Route parameters passed via `extra` or path parameters
- **When adding a new route**: update both `AppRoutes` constants AND `routes.dart` router config

Key route constants:
| Route | Constant |
|-------|----------|
| Splash | `AppRoutes.splash` (`/`) |
| Login | `AppRoutes.login` |
| Dashboard | `AppRoutes.dashboard` |
| Students | `AppRoutes.students` |
| Fees | `AppRoutes.fees` |
| Wallet | `AppRoutes.wallet` / `AppRoutes.fundWallet` |
| Transactions | `AppRoutes.transactions` |
| Profile | `AppRoutes.profile` |
| VAS hub | `AppRoutes.service` |
| Airtime | `AppRoutes.airtimeService` |
| Notifications | `AppRoutes.notifications` |

---

## Design System

**Primary color**: `#1E3A8A` (Dark Navy Blue) — `AppColors.primary`

| Token | Value |
|-------|-------|
| `AppColors.primary` | `#1E3A8A` |
| `AppColors.primaryLight` | `#EAF2FF` |
| `AppColors.primaryDark` | `#132968` |
| `AppColors.surface` | `#F9FAFB` |
| `AppColors.error` | `#EF4444` |
| `AppColors.success` | `#10B981` |
| `AppColors.warning` | `#FB923C` |
| `AppColors.textPrimary` | `#111827` |
| `AppColors.textSecondary` | `#6B7280` |
| `AppColors.border` | `#E5E7EB` |
| `AppColors.balanceGradient` | `[#2E5AC9, #1B3A7D]` |

- Material 3 (`useMaterial3: true`) with M3 tints/overlays explicitly disabled
- `NoSplash.splashFactory` — no ripple/splash effects
- `surfaceTintColor: Colors.transparent` on AppBar, BottomSheet, Dialog
- Input borders: `BorderRadius.circular(12)`, focused border width 2px in primary
- Button border radius: `BorderRadius.circular(12)`
- Always use shimmer loaders for loading states (not just `CircularProgressIndicator`)

---

## Firebase

- **FCM** push notifications initialized in `main()` before `runApp()` via `NotificationService().init()`
- `NotificationService` singleton manages permissions, foreground/background/terminated handling, and token sync
- Optional Google/Apple SSO via `FirebaseAuthService` → hits `ApiEndpoints.authenticateSso`
- `GoogleSignIn.instance.initialize()` called in `main()` with server client ID

---

## Key Conventions

1. **Models**: Define `fromJson(Map<String, dynamic>)` / `toJson()` in `features/<name>/data/models/`
2. **Repository pattern**: Always define an abstract interface; implementation class ends in `Impl`
   - Example: `FeesRepository` (abstract) + `FeesRepositoryImpl` (concrete)
3. **Hive adapters**: Run `dart run build_runner build` after any model change using Hive annotations
4. **Error handling**: Repositories return typed results or throw domain exceptions;
   `DioInterceptor.onError` extracts `data['message'] ?? data['error']` from response
5. **Formatting**: Run `flutter format lib/` before committing
6. **Linting**: Run `flutter analyze` — config in `analysis_options.yaml`
7. **Assets**: Images → `assets/images/`, Icons → `assets/icons/` (both declared in `pubspec.yaml`)
8. **Imports**: Use package imports (`package:blithepay/...`), not relative imports

---

## Commands Reference

```bash
# Dependencies
flutter pub get

# Code generation (run after Hive model changes)
dart run build_runner build

# Development
flutter run                             # Run on connected device/emulator
flutter analyze                         # Lint check
flutter format lib/                     # Format code

# Testing
flutter test                            # All tests
flutter test test/specific_test.dart    # Single test file
flutter test -k "keyword"               # Tests matching keyword

# Production builds
flutter build apk --release             # Android APK
flutter build appbundle --release       # Android App Bundle
flutter build ios --release             # iOS

# Asset generation
dart run flutter_launcher_icons:main    # Regenerate launcher icons
dart run flutter_native_splash:create  # Regenerate splash screen
```
