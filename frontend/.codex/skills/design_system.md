# Design System Skill

## Purpose

This skill defines how Flutter agents must implement the visual design of **My Talking Shaha**.
The product should feel like a dark automotive cockpit: technical, reliable, slightly futuristic, but still readable and friendly.

The UI is based on the uploaded Figma screen exports:
- Auth login and registration screens.
- Garage empty and non-empty states.
- Add car details form.
- Vehicle dashboard.
- History timeline and add record forms.
- Parts/maintenance forecast widget.
- Analytics dashboard.
- Chat empty, normal, and error states.
- Notifications center.
- Settings screen.

## Visual Direction

Use a dark, high-contrast automotive interface:

- deep black/navy app background;
- slightly brighter cards with 1px borders;
- electric blue for primary actions and active navigation;
- cyan for intelligence/data/accent states;
- amber for maintenance warnings;
- soft red/pink for critical states;
- lavender/periwinkle for brand text and selected navigation.

The design should feel like a digital car dashboard, not a generic admin panel.

## Core Colors

Use centralized tokens. Do not hardcode hex colors inside widgets.

Suggested Flutter tokens:

```dart
class AppColors {
  static const background = Color(0xFF0B0E14);
  static const surface = Color(0xFF10131A);
  static const surfaceLow = Color(0xFF151820);
  static const surfaceContainer = Color(0xFF1D2026);
  static const surfaceContainerHigh = Color(0xFF272A31);

  static const primary = Color(0xFF2E5BFF);
  static const primaryLight = Color(0xFFB8C3FF);
  static const cyan = Color(0xFF00DCE5);
  static const amber = Color(0xFFFFD393);
  static const warning = Color(0xFFFFBA43);
  static const critical = Color(0xFFFFB4AB);

  static const textPrimary = Color(0xFFE1E2EB);
  static const textSecondary = Color(0xFFC4C5D9);
  static const textMuted = Color(0xFF8E90A2);

  static const outline = Color(0xFF434656);
  static const outlineStrong = Color(0xFF5A5E70);
}
```

## Typography

Use one main sans-serif font across the app. Prefer Inter if available.
If the project does not include a custom font yet, use the default Flutter font but keep the same hierarchy.

Typography hierarchy:

- Large brand title: 32-40sp, bold, primaryLight.
- Screen title: 24-28sp, semibold/bold, textPrimary or primaryLight.
- Section title: 12-14sp, uppercase, letter spacing, textSecondary.
- Body text: 14-16sp, textSecondary.
- Data numbers: 24-36sp, bold, textPrimary/primaryLight.
- Small labels: 10-12sp, uppercase, letter spacing.

Use uppercase labels for technical metadata:

- `ПРОБЕГ`
- `ДВИГАТЕЛЬ`
- `VIN НОМЕР`
- `ПРОГНОЗ ОБСЛУЖИВАНИЯ`
- `ПОСЛЕДНИЕ СОБЫТИЯ`

## Layout and Spacing

Use an 8px spacing scale.

Recommended values:

- screen horizontal padding: 20px;
- section gap: 24px;
- card internal padding: 16px;
- card gap: 12px or 16px;
- small row gap: 8px;
- bottom navigation height: 72-88px;
- main CTA button height: 56px;
- input height: 56px.

The UI should use generous padding and avoid cramped layouts.

## Shapes

Use rounded shapes consistently:

- cards: 12-16px radius;
- primary buttons: 12-16px radius;
- inputs: 8-12px radius;
- chips/badges: 8-999px radius depending on shape;
- bottom nav: top radius / subtle rounded container if custom shell is used.

Avoid sharp corners.

## Cards

Most screens are built from dark cards.

Card rules:

- background: `surfaceContainer` or a subtle gradient from `surfaceContainer` to `surfaceLow`;
- border: 1px solid `outline` with low opacity;
- no heavy drop shadows;
- subtle glow is allowed for active/primary elements only;
- cards must remain readable without blur effects.

Use a common `ShahaCard` component for regular cards.

## Buttons

Primary buttons:

- background: primary electric blue;
- text: white/textPrimary;
- height: at least 52-56px;
- bold label;
- optional trailing arrow icon for forward actions.

Secondary buttons:

- dark surface background;
- 1px outline;
- textPrimary or primaryLight.

Destructive buttons:

- use critical color only for text/icon unless the action is final and confirmed.

## Inputs

Input fields are dark and bordered.

Input rules:

- background: near-black/surfaceLow;
- border: outline;
- focused border: primaryLight or primary;
- prefix icons use textMuted;
- placeholder text uses textMuted;
- validation errors use critical.

Forms must use consistent vertical spacing and field labels.

## Navigation

Top area:

- most screens use a compact top app bar with a menu/back icon and centered or left-aligned title;
- title should use primaryLight when it represents the brand.

Bottom navigation:

- dark floating bar or attached bottom bar;
- items: Garage, History, Chat, Analytics, Settings depending on implemented routes;
- active icon/label: primaryLight;
- inactive icon/label: textMuted;
- keep the selected tab visually obvious.

## Screen-Specific Guidance

### Auth

Auth screens use:

- dark abstract/gradient background;
- large centered brand title;
- glass-like form card;
- fields for login/email/password;
- primary CTA;
- social auth button if supported by backend;
- switch link between login and registration.

Note: current mockups show `YandexID`, while user stories mention Google OAuth. Implementation must follow the current product decision and backend contract. If unresolved, use a generic social auth component and avoid hardcoding a provider in business logic.

### Garage

Garage screens use:

- title `Моя Говорящая Шаха`;
- section label `ТВОЙ ПАРК`;
- screen title `Гараж`;
- large vehicle cards with image, brand/model, subtitle, quick metrics, and primary action `В кабину`;
- floating/add button near the title area;
- empty state with assistant/car icon and CTA `Добавить авто`.

### Vehicle Dashboard

Vehicle dashboard uses:

- top app bar;
- large hero vehicle image card;
- stat cards for mileage and engine;
- VIN card;
- embedded parts feature widget / maintenance forecast card;
- recent events list;
- bottom navigation.

The dashboard must feel glanceable: important vehicle status must be visible before long lists.

### Parts Widget

The parts widget is a reusable component from the `parts` feature.
It appears on the vehicle dashboard and analytics screen.

It shows:

- section title `ПРОГНОЗ ОБСЛУЖИВАНИЯ`;
- last updated label;
- next maintenance forecast;
- resource badge;
- several part resource rows with progress bars and statuses.

Status colors:

- OK: primaryLight/cyan;
- Warning: amber;
- Critical: critical red/pink;
- Unknown: textMuted.

### History

History screens use:

- title `История обслуживания`;
- search field and filter/settings icon;
- category chips such as all/fuel/repair/trips;
- date/month grouping;
- event cards with icon circle, title, details, date/time, amount or distance;
- FAB for adding a record.

Add record screens use tabs for event type:

- maintenance;
- refuel;
- trip.

Forms should be long-scrollable and use the same dark input style.

### Analytics

Analytics screen uses:

- title `Intelligence` or analytics app bar;
- headline `Аналитика`;
- yearly expenses summary card;
- monthly expenses chart card;
- reused parts widget;
- history analysis card;
- period selector chips.

Charts should be simple and readable. Use app colors, not random chart palettes.

### Chat

Chat screens use:

- app bar with title `Чат с Шахой` or brand title;
- empty state with assistant icon and suggested starter questions;
- user messages as blue/dark primary bubbles aligned right;
- assistant messages as dark bordered bubbles aligned left with avatar/icon;
- error/insufficient-data state inside assistant bubble;
- input bar fixed at bottom with text field and mic/send button.

### Notifications

Notifications center uses:

- list of warning/recommendation cards;
- severity colors for icons/statuses;
- unread/read visual difference if available;
- CTA to open part/details/recommendation.

### Settings

Settings screen uses:

- profile header card;
- account section;
- preferences section;
- notification toggle;
- about/app section;
- logout action.

Do not overload the settings screen with product-critical content.

## Component Inventory

Create reusable components before duplicating UI across screens:

Core:

- `ShahaScaffold`
- `ShahaTopBar`
- `ShahaBottomNavBar`
- `ShahaCard`
- `ShahaButton`
- `ShahaTextField`
- `ShahaSectionHeader`
- `StatusChip`
- `MetricCard`
- `EmptyState`
- `LoadingView`
- `ErrorView`
- `ConfirmDialog`

Feature widgets:

- `VehicleCard`
- `VehicleHeroCard`
- `VehicleStatCard`
- `RecentEventTile`
- `MaintenanceForecastCard`
- `PartResourceRow`
- `HistoryEventCard`
- `HistoryFilterChips`
- `HistoryFormScaffold`
- `AnalyticsSummaryCard`
- `ChartCard`
- `ChatBubble`
- `ChatInputBar`
- `NotificationCard`
- `SettingsSection`

## Implementation Rules

- Do not implement screens by copying large one-off widget trees.
- Extract repeated cards, buttons, inputs, section headers, and event rows.
- Do not hardcode colors in screen widgets.
- Do not hardcode text styles in every widget; use theme or shared text styles.
- Keep business logic out of widgets.
- Use mock data only when backend is not ready.
- Preserve accessibility: readable contrast, tappable targets >= 44px, scrollable forms.
