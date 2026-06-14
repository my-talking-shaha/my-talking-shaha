# Flutter Feature-First Architecture Skill

## Goal

Keep Flutter code modular, reviewable, and aligned with product features.

## Expected Structure

```text
lib/
  app/
  core/
  features/
    feature_name/
      presentation/
      domain/
      data/
```

## Feature Layers

### presentation

Contains:
- screens;
- widgets;
- controllers/providers;
- UI state;
- form state;
- navigation triggers.

Must not contain:
- HTTP calls;
- JSON parsing;
- DTO classes;
- database code;
- complex business rules.

### domain

Contains:
- entities;
- repository contracts;
- use cases;
- pure business rules.

Rules:
- no Flutter imports;
- no DTOs;
- no API-specific models;
- no platform-specific code;
- no UI state.

### data

Contains:
- DTOs;
- datasources;
- repository implementations;
- mappers.

Rules:
- API responses are parsed here;
- DTOs are mapped into domain entities;
- repository implementations live here;
- data models must not leak into presentation.

## Core

Use `core/` only for reusable infrastructure:
- network client;
- API errors;
- storage;
- common UI primitives;
- theme tokens;
- formatters;
- shared validators only if truly generic.

## Feature Ownership

Suggested features:
- `auth`
- `garage`
- `vehicle`
- `history`
- `parts`
- `analytics`
- `chat`
- `notifications`
- `settings`

If one feature needs another feature's data, prefer a shared domain abstraction or repository exposed via providers. Do not import internal presentation/data classes from another feature.
