# Architecture Review Checklist

## Feature-first

Check:
- Does the change belong to the modified feature?
- Are shared components placed in `core/` only when truly reusable?
- Is there any unrelated refactoring?
- Are features independent and not importing each other's internal data/presentation files?

## Layer Boundaries

Check:
- Presentation contains screens, widgets, controllers/providers, UI state.
- Domain contains entities, repository contracts, use cases, pure rules.
- Data contains DTOs, datasources, repository implementations, mappers.
- Dependencies flow inward: presentation -> domain -> data through provider wiring.

## Forbidden Violations

- Widget parses JSON.
- Widget/controller calls HTTP client directly.
- Domain imports Flutter, http, GoRouter, or platform packages.
- DTO leaks into UI.
- Repository implementation is placed in domain.
- API model is used as UI state.
- Generated fake live telemetry is shown as real data.

## Navigation

Check:
- Routes are defined centrally.
- `vehicleId` is passed through route parameters where needed.
- Auth redirects do not create loops.
- Deep links/refresh states are not broken by global-only selected vehicle state.

## State

Check:
- State is localized to the feature.
- Async state handles loading/error/data.
- Controllers do not become god objects.
- Derived display data is not duplicated inconsistently.

## Documentation

Check:
- Flow docs are respected.
- Contract docs match data layer implementation.
- If the backend contract changed, docs were updated in the same diff.
