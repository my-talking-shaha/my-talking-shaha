# Riverpod Skill

## Goal

Use Riverpod consistently for dependency injection and state management.

## Provider Types

Use:
- `Provider` for stable dependencies: API client, repositories, use cases.
- `FutureProvider` for simple read-only async data.
- `Notifier` / `AsyncNotifier` for screens with mutable actions.
- Immutable state classes for form and screen state.

## Patterns

### Dependency wiring

```dart
final vehicleRepositoryProvider = Provider<VehicleRepository>((ref) {
  final datasource = ref.watch(vehicleRemoteDatasourceProvider);
  return VehicleRepositoryImpl(datasource);
});
```

### Screen controller

Controllers should:
- expose immutable state;
- call use cases;
- map exceptions to user-friendly errors;
- prevent duplicate submissions;
- avoid direct HTTP/data parsing.

### Async handling

Every async screen must handle:
- loading;
- data;
- empty;
- error;
- retry when appropriate.

## Do Not

- Do not create global mutable singletons for feature state.
- Do not call repositories directly from widgets if a controller/use case is appropriate.
- Do not refetch data on every rebuild.
- Do not mix Provider, Bloc, GetX, and setState-based screen logic in one feature without approval.

## Product-specific Guidance

- Auth session should be centralized.
- Current vehicle should be route-driven by `vehicleId`, not only global state.
- Chat state must be scoped by vehicle ID.
- Timeline filters/search should not reload from backend on every keystroke unless debounced.
