# Parts Behavior and Design Baseline

This document captures the `parts` presentation behavior and visuals before the
structure-only refactor. It is the reference when comparing the refactored
feature.

## Entry and navigation

- When hosted at the intended and widget-tested `/vehicle/:vehicleId/parts`
  route, its route parameter scopes the request. The standalone screen is not
  currently registered in the production router; the reusable card is embedded
  in dashboard and analytics UI.
- The app bar title is the localized `Maintenance forecast` label.
- The back arrow navigates directly to `/garage` with `go`, rather than popping
  the current route.
- There are no forms, editable fields, submit actions, horizontal carousels,
  swipe-to-dismiss actions, or directional swipe navigation in this feature.
- Loaded content is a vertical `ListView`. Vertical swipes scroll long content;
  horizontal swipes have no feature-specific effect.

## Async states

- Loading shows a centered amber circular progress indicator.
- An empty result shows a centered build icon, localized empty title, and
  localized explanation.
- An error shows a red error icon, localized error copy, and an outlined retry
  action.
- Retry invalidates the provider for the same `vehicleId` and repeats the
  request.
- A non-empty result shows one reusable `MaintenanceForecastCard` containing all
  returned parts in their original order.

## Forecast calculations used for presentation

- The resource badge is the rounded average of all known percentages. Each
  percentage is clamped to `0..100` before averaging. If all lifetimes are
  unknown, the badge shows `--`.
- Any critical part takes precedence over a future forecast. The headline is
  `Service needed now`; the caption names one critical part or reports the
  number of critical parts.
- Without critical parts, the nearest strictly positive `remainingKm` is shown.
  The approximate window divides it by 53 km/day and rounds days upward.
- With neither critical nor positive known resource, the card shows insufficient
  data and prompts the user to add lifetime data.
- Known rows show a clamped percentage and a non-negative kilometer value.
  Thousands are separated with spaces. Unknown rows show `Lifetime not set` and
  a solid muted progress track.

## Layout and typography

- Screen content padding: 20 px left/right, 16 px top, 32 px bottom.
- Card radius: 16 px. Progress height: 7 px.
- Card body padding: 20 px left, 24 px top/bottom, 16 px right.
- Resource badge: 92 x 86 px with 12 px internal padding.
- Forecast headline: 30 px, weight 700. Resource value: 30 px, weight 900.
- Part name: 17 px, weight 700. Part resource: 14 px, weight 700.

## Explicit parts palette

| Token | ARGB/hex | Use |
| --- | --- | --- |
| `headerText` | `#FFC4C5D9` | section label |
| `headerTextMuted` | `#FFB8C3FF` | last-updated label |
| `cardBackground` | `#FF1C1F25` | forecast card and empty icon tile |
| `bodyText` | `#FFE1E2EB` | forecast labels/headline |
| `bodyTextMuted` | `#FFC4C5D9` | forecast caption |
| `progressTrack` | `#FF343841` | known-resource track |
| `badgeBackground` | `#FF4A3A17` | resource badge fill |
| `badgeBorder` | `#FF8B6500` | resource badge border |
| `accent` / `warning` | `#FFFFD08A` | maintenance icon, loader, warning status |
| `ok` | `#FFADB5FF` | healthy resource row |
| `critical` | `#FFFFAAA5` | critical resource row |
| `unknown` | `#FF8E90A2` | unknown resource row/track |
| `border` | `#FF2B303B` | forecast card border |
| `error` | `#FFE85D75` | error-state icon |

Inherited screen colors remain those of `AppTheme.dark`: background
`#FF10131A`, primary text `#FFF4F7FF`, secondary text `#FF9AA3B2`, and outlined
button border `#FF2B303B`.
