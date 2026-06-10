# My Talking Shaha — Flutter Harness

This repository contains the mobile Flutter client for **My Talking Shaha**, a platform for creating a digital car twin. The app stores vehicle data, trips, refueling, repairs, maintenance, part lifetime, analytics, and AI assistant conversations.

The project is planned as a 7-week MVP:

1. Requirements, repository, competitors, user stories, initial design.
2. Backend/frontend/database foundations.
3. User auth, profile, garage, multiple cars, car dashboard integration.
4. Vehicle timeline: trips, refueling, repairs, maintenance CRUD.
5. Analytics, dashboard widgets, digital twin status indicators.
6. AI assistant, rule-based predictive maintenance, part lifetime, reminders.
7. Testing, documentation, presentation, final demo.

## Harness purpose

The `.codex/` and `docs/` folders are the operating system for AI-assisted development. They define:

- agent roles;
- workflows for feature work and bug fixes;
- architecture, review, and quality rules;
- Flutter-specific implementation skills;
- product flows and API contracts.

Agents and contributors must read `AGENTS.md` first.

## Core architecture

The Flutter client uses feature-first architecture:

```text
lib/
  app/
  core/
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

Each feature uses layers:

```text
feature_name/
  presentation/
  domain/
  data/
```

Dependency direction:

```text
presentation -> domain -> data
```

## Required checks

```bash
.codex/scripts/check.sh
```

Equivalent commands:

```bash
dart format --set-exit-if-changed .
flutter analyze
flutter test
```

Never claim checks passed if they were not run.
