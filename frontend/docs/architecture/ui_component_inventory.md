# UI Component Inventory

This document maps the uploaded design screens to reusable Flutter components.
Agents must prefer these components over one-off widget trees.

## App-Level Components

### `ShahaScaffold`

Common dark page wrapper.

Responsibilities:
- apply app background;
- handle safe area;
- optionally render top bar;
- optionally render bottom navigation;
- provide consistent horizontal padding.

### `ShahaTopBar`

Common header/app bar.

Variants:
- centered brand title;
- left title with back/menu icon;
- title + profile/avatar action;
- title + notification/settings action.

### `ShahaBottomNavBar`

Bottom navigation component.

Items may include:
- Garage;
- History;
- Chat;
- Analytics;
- Settings.

Active state uses primaryLight. Inactive state uses textMuted.

### `ShahaCard`

Base card container.

Props:
- child;
- padding;
- onTap;
- gradient optional;
- border color optional;
- radius optional.

Used by almost every screen.

### `ShahaButton`

Base button component.

Variants:
- primary;
- secondary;
- ghost;
- destructive;
- icon.

### `ShahaTextField`

Dark input field with label, placeholder, prefix/suffix icons, validation error.

Used in:
- auth;
- add car;
- add history record forms;
- chat input if appropriate.

### `ShahaSectionHeader`

Uppercase section title with optional trailing action.

Examples:
- `ПРОГНОЗ ОБСЛУЖИВАНИЯ` + `ОБНОВЛЕНО 2 ЧАСА НАЗАД`
- `ПОСЛЕДНИЕ СОБЫТИЯ` + `Все`
- `ЕЖЕМЕСЯЧНЫЕ РАСХОДЫ`

## Auth Components

### `AuthBackground`

Dark abstract gradient background used by login/register screens.

### `AuthFormCard`

Glass-like card containing fields and actions.

### `SocialAuthButton`

Generic social auth button.
Do not hardcode provider logic inside UI. Current auth UI shows a Yandex ID placeholder until OAuth/backend integration is implemented.

## Garage Components

### `VehicleGarageCard`

Large car card used in Garage.

Displays:
- car image;
- brand/model;
- subtitle/status;
- quick metrics;
- primary action `В кабину`.

### `GarageEmptyState`

Empty garage screen with assistant/car icon, explanation, and add button.

### `AddVehicleFab`

Circular primary add button.

## Vehicle Components

### `VehicleHeroCard`

Large image card for the selected vehicle.

Displays:
- car image;
- brand/model title overlay.

### `VehicleMetricCard`

Compact metric card.

Examples:
- mileage;
- engine;
- active warnings;
- last maintenance.

### `VinCard`

Full-width VIN card with copy action.

### `RecentEventTile`

Compact timeline event preview used on dashboard.

## Parts Components

### `MaintenanceForecastCard`

Reusable parts feature widget.

Used by:
- vehicle dashboard;
- analytics dashboard.

Displays:
- next maintenance forecast;
- resource badge;
- part resource rows.

### `PartResourceRow`

Displays:
- part name;
- edit icon optional;
- remaining percent/km;
- progress bar;
- status color.

### `ResourceBadge`

Large percentage badge shown inside the maintenance forecast card.

## History Components

### `HistorySearchBar`

Search field with filter/settings action.

### `HistoryFilterChips`

Category filter chips.

Examples:
- all;
- fuel;
- repair;
- trips;
- maintenance.

### `HistoryEventCard`

Timeline event card.

Displays:
- icon;
- title;
- description;
- time/date;
- cost/distance if available.

### `HistoryFormScaffold`

Shared layout for add maintenance/refuel/trip forms.

### `HistoryTypeTabs`

Tabs for selecting record type.

## Analytics Components

### `AnalyticsSummaryCard`

Large annual/period expense card.

### `ExpenseCategoryGrid`

Small category values inside analytics summary.

### `ChartCard`

Reusable chart container.

### `PeriodSelector`

Month/year/all-time selector.

### `HistoryAnalysisCard`

Chart + repair frequency + mileage dynamics card.

## Chat Components

### `ChatEmptyState`

Empty chat screen with assistant icon and suggested starter questions.

### `ChatBubble`

Message bubble.

Variants:
- user bubble;
- assistant bubble;
- assistant error/insufficient-data bubble.

### `ChatInputBar`

Bottom input bar with text field and mic/send action.

## Notifications Components

### `NotificationCard`

Warning/recommendation card.

Displays:

- severity icon;
- title;
- description;
- related vehicle/part when available;
- time/date;
- read/unread state;
- recommended action;
- optional CTA.

## Settings Components

### `ProfileHeaderCard`

Displays signed-in user avatar or initials, display name, and email.

### `SettingsSection`

Grouped settings block.

### `SettingsTile`

Single settings row with icon, label, optional trailing value/toggle.

## Extraction Rules

Before implementing a new screen, check this component inventory.
If a component with similar structure exists, extend it instead of creating a duplicate.
