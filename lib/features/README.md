# EduFlow Feature Architecture Guidelines

Every feature folder inside `lib/features/` follows strict Clean Architecture & Separation of Concerns:

```
lib/features/<feature_name>/
├── data/
│   ├── datasources/        # Remote Dio & Local Hive Data Sources
│   ├── dtos/               # Freezed / JsonSerializable Data Transfer Objects
│   └── repositories/       # Concrete Repository Implementations
├── domain/
│   ├── entities/           # Pure Dart Domain Entities
│   ├── repositories/       # Abstract Repository Interfaces
│   └── usecases/           # Independent Business Logic Operations
├── application/
│   ├── services/           # Feature Application Services
│   └── providers/          # Riverpod State Notifiers & Providers
└── presentation/
    ├── screens/            # Screen Views (ConsumerWidget)
    ├── controllers/        # Screen ViewControllers & State Notifiers
    └── widgets/            # Feature-specific UI Widgets
```

## Rules
1. **No UI Business Logic**: Widgets must never handle raw async network requests or state mutations directly. Use Riverpod `Notifier` / `AsyncNotifier`.
2. **State Requirements**: Every list/details screen MUST support:
   - **Loading State**: `AppSkeletonShimmer`
   - **Empty State**: `AppEmptyState`
   - **Error State**: `AppErrorView` with `onRetry`
   - **Offline State**: `OfflineBannerWrapper`
