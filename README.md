# e-Drive

A ride-hailing app (Uber/InDrive-style) built with Flutter using **Clean Architecture + Feature-First** structure and **Riverpod** for state management.

## Architecture

```
lib/
├── main_dev.dart / main_staging.dart / main_prod.dart
├── app.dart               # MaterialApp.router + ProviderScope
├── main_shell.dart        # Bottom nav shell (role-aware)
│
├── core/
│   ├── di/injection.dart  # GetIt manual DI
│   ├── network/           # Dio + AuthInterceptor + Endpoints
│   ├── router/            # GoRouter + AppRoutes constants
│   ├── services/          # TokenStorage, AuthGuard, LocationService, SocketService
│   ├── error/             # Failures + DioErrorHandler
│   ├── theme/             # Colors, TextStyles, Spacing, AppTheme
│   ├── utils/             # Formatters (currency, phone, distance)
│   └── widgets/           # AppButton, AppTextField, InAppWebViewPage
│
└── features/
    ├── auth/              # Login, Register, OTP, ForgotPassword, RoleSelect
    ├── ride/              # Book ride, tracking, complete — rider flow
    ├── driver/            # Online toggle, dashboard, earnings, vehicle
    ├── trips/             # Ride history + detail
    ├── profile/           # User profile + edit
    ├── payment/           # Payment methods, add card, Paystack WebView
    └── map/               # Place search, fare estimate, nearby drivers
```

## State Management — Riverpod

Each feature has providers in `presentation/providers/`:

| Pattern | When to use |
|---|---|
| `FutureProvider` | One-shot async data (profile, earnings, methods list) |
| `StateNotifierProvider` | Complex mutable state with methods (auth, active ride, driver online) |
| `StateProvider` | Simple atomic state (selected payment method, search query) |

### Example provider
```dart
// StateNotifierProvider for complex state
final activeRideProvider = StateNotifierProvider<ActiveRideNotifier, ActiveRideState>(
  (ref) => ActiveRideNotifier(getIt<RequestRideUseCase>(), ...),
);

// FutureProvider for read-only async data
final profileProvider = FutureProvider<ProfileEntity>((ref) async {
  final result = await getIt<GetProfileUseCase>()();
  return result.fold((f) => throw f.message, (p) => p);
});
```

## Clean Architecture Layers

```
domain/
  entities/     Pure Dart. Zero Flutter deps.
  repositories/ Abstract interfaces.
  usecases/     Single-responsibility business logic.

data/
  models/       JSON parsing. fromJson() + toEntity()
  datasources/  Remote (Dio) and Local (SharedPrefs)
  repositories/ Implements domain interface. Returns Either<Failure, T>

presentation/
  providers/    Riverpod providers + StateNotifiers
  pages/        ConsumerWidget / ConsumerStatefulWidget
  widgets/      Reusable UI components
```

## Key APIs

| Endpoint | Method | Description |
|---|---|---|
| `/auth/login` | POST | phone + password → token + user |
| `/auth/register` | POST | name, phone, email, password, role |
| `/auth/verify-otp` | POST | OTP verification |
| `/rides/request` | POST | Request a new ride |
| `/rides/cancel` | POST | Cancel active ride |
| `/rides/history` | GET | Paginated ride history |
| `/rides/:id/track` | GET | Live ride tracking |
| `/driver/online` | POST | Go online with location |
| `/driver/offline` | POST | Go offline |
| `/driver/rides/accept` | POST | Accept incoming ride |
| `/driver/earnings` | GET | Earnings summary |
| `/map/fare-estimate` | GET | Fare estimates by vehicle type |
| `/map/nearby-drivers` | GET | Drivers near coordinates |
| `/map/search` | GET | Place search autocomplete |
| `/payments/methods` | GET | User payment methods |
| `/payments/initiate` | POST | Initiate Paystack payment |

## Getting Started

```bash
flutter pub get
make run-dev       # Development
make run-prod      # Production
make build-apk-prod
```

## Adding a New Feature

1. Create `lib/features/{name}/`
2. Add **entity** in `domain/entities/`
3. Add **abstract repository** in `domain/repositories/`
4. Add **use cases** in `domain/usecases/`
5. Add **datasource** (abstract + impl) in `data/datasources/`
6. Add **model** with `fromJson()` + `toEntity()` in `data/models/`
7. Add **repository impl** in `data/repositories/`
8. Add **providers** in `presentation/providers/`
9. Add **pages** in `presentation/pages/`
10. Register in `injection.dart`
11. Add route in `app_routes.dart` + `app_router.dart`
