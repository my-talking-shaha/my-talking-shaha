# AGENTS.md — My Talking Shaha Flutter Client

## 1. Project Overview

**My Talking Shaha** is a Flutter mobile client for creating a digital car twin.

The product lets a user:
- register and log in;
- manage several cars in a garage;
- open a selected car dashboard;
- store trips, refueling, repairs, maintenance, and technical records;
- track parts and remaining lifetime;
- see analytics for mileage, costs, repairs, refueling, and maintenance;
- receive warnings and reminders;
- talk to a per-car AI assistant grounded in the car's stored data.

The product idea is to turn a vehicle and its maintenance records into an alive digital entity: a structured vehicle timeline plus an experimental conversational interface.

## 2. MVP Priority

Use this order unless the human explicitly changes scope.

### Must
- Email/password registration and login.
- Empty garage is created after registration.
- Garage list with multiple cars.
- Add, view, select, and delete cars.
- Vehicle dashboard with key summary data.
- Timeline CRUD for trips, refueling, repairs, and maintenance.
- Mileage validation: new mileage cannot go backwards.
- Current condition summary.
- Part remaining lifetime display.
- Per-vehicle AI chat with grounded answers.

### Should
- YandexID auth.
- Parts catalog and default lifetime values.
- Analytics for expenses, mileage, repairs, refueling, and maintenance.

### Could
- Vehicle photo gallery / simplified 3D representation.
- Push notifications.
- Voice input in chat.

## 3. Architecture

The Flutter client follows feature-first architecture.

Expected structure:

```text
lib/
  app/
    app.dart
    router/
    theme/
  core/
    config/
    errors/
    network/
    storage/
    ui/
    utils/
  features/
    auth/
    garage/
    vehicle/
    history/
    parts/
    analytics/
    chat/
    notifications/
    settings/
```

Each feature should use:

```text
feature_name/
  presentation/
    screens/
    widgets/
    controllers/ or providers/
    state/
  domain/
    entities/
    repositories/
    use_cases/
  data/
    dto/
    datasources/
    repositories/
    mappers/
```

Dependency direction:

```text
presentation -> domain -> data
```

Rules:
- UI reads domain entities or UI models, not raw DTOs.
- Domain must not import Flutter, Dio, GoRouter, Riverpod annotations, or platform packages.
- Data layer owns DTO parsing, API calls, persistence, and mapping.
- Presentation owns screens, widgets, UI state, form state, navigation triggers, and user interaction.
- Business rules must live in domain use cases when they are not purely visual.

## 4. State Management

Use Riverpod consistently.

Preferred patterns:
- `Provider` for stable dependencies and use cases.
- `FutureProvider` for simple read-only async data.
- `Notifier` / `AsyncNotifier` for mutable flows and screens.
- Immutable state objects for screen state.
- `AsyncValue` or explicit state classes for loading/error/data.

Do not introduce another state management approach without approval.

## 5. Navigation

Use GoRouter consistently.

Expected route groups:

```text
/splash
/auth/login
/auth/register
/garage
/garage/add
/vehicle/:vehicleId
/vehicle/:vehicleId/history
/vehicle/:vehicleId/history/add
/vehicle/:vehicleId/parts
/vehicle/:vehicleId/analytics
/vehicle/:vehicleId/chat
/settings
/notifications
```

Use route parameters for `vehicleId`. Do not keep the currently selected vehicle only in global mutable state.

## 6. API and Contracts

API contracts are documented in `docs/contracts/` and are the source of truth until backend provides a newer contract.

General assumptions:
- Base path: `/api/v1`.
- JSON uses `camelCase`.
- Timestamps use ISO-8601 strings.
- Authenticated endpoints require `Authorization: Bearer <accessToken>`.
- Errors use a stable error envelope.
- The client must not invent server fields.

If backend differs from docs, update `docs/contracts/*.md` first or in the same diff.

## 7. Design System

Follow `docs` and `.codex/skills/design_system.md`.

Visual direction:
- dark automotive dashboard;
- midnight surfaces;
- electric-blue primary actions;
- cyan technical accents;
- amber warnings;
- red critical errors;
- Inter typography;
- 8px spacing rhythm;
- rounded cards and glassmorphism-inspired surfaces.

Do not implement generic default Material screens when project-specific design guidance exists.

## 8. Core Rules

- Prefer minimal safe diffs.
- Preserve feature-first architecture.
- Reuse existing abstractions before creating new ones.
- Do not introduce dependencies without explicit approval.
- Do not move large amounts of code without need.
- Do not mix unrelated refactors with feature work.
- Keep code reviewable.
- Do not hide failing checks.
- Do not fabricate product behavior not present in docs/user stories.
- Never store secrets or tokens in source code.
- Never log access tokens, refresh tokens, passwords, or private user data.

## 9. Context Discovery

Before implementing, inspect:
- `AGENTS.md`;
- the relevant `.codex/agents/*.md` role file;
- the relevant workflow in `.codex/workflows/`;
- relevant skills from `.codex/skills/`;
- `docs/architecture/overview.md`;
- relevant `docs/flows/*.md`;
- relevant `docs/contracts/*.md`;
- existing feature code in `lib/features/<feature>/`.

Do not create parallel abstractions until existing implementations are inspected.

## 10. Checks

Required before completion:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Preferred command:

```bash
.codex/scripts/check.sh
```

If checks cannot run, say exactly why.

## 11. Review Expectations

Changes must be:
- architecture-consistent;
- easy to reason about;
- small enough to review;
- aligned with user stories and contracts;
- tested when behavior changes.

Severity levels:
- `[P0]` crash, data loss, security issue, app cannot build.
- `[P1]` broken user flow, architecture violation, incorrect API contract usage.
- `[P2]` maintainability, naming, style, missing small test.

## 12. Forbidden Actions

Do not:
- put HTTP code in widgets/controllers;
- parse JSON in widgets;
- import Flutter from domain layer;
- leak DTOs into UI;
- hardcode API base URLs except through approved config;
- commit secrets;
- log tokens/passwords;
- create another router/state-management stack;
- implement fake live telemetry unless explicitly requested;
- make the AI assistant answer without data grounding.

## 13. Output Format

For implementation tasks:

```md
### Summary
### Files Changed
### Checks Run
### Assumptions
### Risks
### Notes for Reviewer
```

For planning tasks:

```md
### Understanding
### Proposed Approach
### Files to Inspect
### Files Likely to Change
### Risks
### Questions for Human
```

For review tasks:

```md
### Verdict
APPROVE / REQUEST CHANGES
### Findings
### Missing Checks
### Suggested Fixes
```

## 14. References

Architecture:
- `docs/architecture/overview.md`

Flows:
- `docs/flows/auth_flow.md`
- `docs/flows/garage_flow.md`
- `docs/flows/vehicle_flow.md`
- `docs/flows/history_flow.md`
- `docs/flows/parts_flow.md`
- `docs/flows/analytics_flow.md`
- `docs/flows/notifications_flow.md`
- `docs/flows/chat_flow.md`
- `docs/flows/settings_flow.md`

Design notes:
- `docs/flows/*_design_notes.md`

Design examples:
- `docs/design/screenshots/*`

Contracts:
- `docs/contracts/auth_api.md`
- `docs/contracts/garage_api.md`
- `docs/contracts/vehicle_api.md`
- `docs/contracts/history_api.md`
- `docs/contracts/parts_api.md`
- `docs/contracts/analytics_api.md`
- `docs/contracts/notifications_api.md`
- `docs/contracts/chat_api.md`
- `docs/contracts/settings_api.md`

Skills:
- `.codex/skills/feature_first_architecture.md`
- `.codex/skills/riverpod.md`
- `.codex/skills/go_router.md`
- `.codex/skills/api_layer.md`
- `.codex/skills/design_system.md`
- `.codex/skills/forms_validation.md`
- `.codex/skills/error_handling.md`
- `.codex/skills/ai_chat.md`
