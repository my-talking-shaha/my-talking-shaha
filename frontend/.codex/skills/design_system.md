# Design System Skill

## Goal

Keep the Flutter UI consistent with the My Talking Shaha visual language.

## Visual Direction

The app should feel like a futuristic automotive co-pilot and digital dashboard:
- dark cockpit-like surfaces;
- premium glassmorphism-inspired cards;
- electric-blue actions;
- cyan technical indicators;
- amber warnings;
- red critical states;
- strong data hierarchy.

## Core Tokens

Use these values as design targets unless the Flutter theme already defines tokens.

```text
background: #10131A
surface lowest: #0B0E14
surface low: #191C22
surface: #1D2026
surface high: #272A31
surface highest: #32353C
onSurface: #E1E2EB
onSurfaceVariant: #C4C5D9
outline: #8E90A2
outlineVariant: #434656
primary: #B8C3FF
primaryContainer: #2E5BFF
secondary/amber: #FFD393
tertiary/cyan: #00DCE5
error: #FFB4AB
```

## Typography

Use Inter or project theme equivalent.

Recommended roles:
- title/header: bold/semi-bold, high contrast;
- labels: uppercase, letter spaced, 12px style;
- technical numbers: 24px+ bold;
- body text: 16px, readable line height.

## Spacing and Shape

- Base spacing: 8px.
- Screen horizontal padding: 20px.
- Section gap: 24px.
- Card radius: 16px.
- Button/input radius: 24px.
- Minimum tap target: 48px, preferred 56px for primary actions.

## Components

Prefer building reusable primitives in `core/ui/`:
- `AppScaffold`
- `AppCard`
- `PrimaryButton`
- `SecondaryButton`
- `StatusChip`
- `MetricTile`
- `TimelineCard`
- `VehicleHeroCard`
- `EmptyState`
- `ErrorState`

## Status Colors

- OK: cyan/green-tinted status.
- Warning: amber.
- Critical: error/red.
- Unknown/no data: neutral grey.

## Screen Guidance

### Auth
- Large brand title.
- Dark glass-like form card.
- Clear primary submit button.
- Secondary social buttons.

### Garage
- Vehicle cards with image, model, mileage, status.
- Empty state must guide user to add first car.
- Active/selected car should be visually stronger.

### Vehicle Dashboard
- Hero vehicle image.
- Key metrics as cards.
- Current condition summary.
- Last 5 events.
- No fake live telemetry unless backend provides it.

### History
- Search/filter chips.
- Timeline grouped by date/month.
- Event cards with type, description, mileage, cost, date.

### Chat
- Per-car assistant identity.
- User/assistant bubbles.
- Structured recommendation cards when backend returns actions.
- Standard insufficient-data message for missing context.

## Do Not

- Do not use plain white backgrounds.
- Do not mix random colors outside status/action semantics.
- Do not create every screen with default Material look.
- Do not use tiny tap targets.
- Do not display ungrounded sensor values like engine temperature unless API provides them.
