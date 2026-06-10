# My Talking Shaha

This repository contains the mobile Flutter client for **My Talking Shaha**, a platform for creating a digital car twin. The app stores vehicle data, trips, refueling, repairs, maintenance, part lifetime, analytics, and AI assistant conversations.

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
