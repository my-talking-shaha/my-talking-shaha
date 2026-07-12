# Notifications Design Notes

## Screen From Design

- Refer to `docs/design/screenshots/01_notofications.jpg` for the design example.
- The exact implemented pre-refactor baseline is recorded in
  `notifications_current_baseline.md` and its golden snapshot.

## Visual Structure

The notifications center shows warning and recommendation cards related to vehicle condition and parts lifetime.

Screen structure:

- top app bar/title;
- list of notification cards;
- empty state when there are no notifications;
- loading and error states;
- severity indicators;
- time/date;
- recommended action;
- optional CTA to open part/details.

## Notification Card Content

Each notification may display:

- severity icon;
- title;
- short explanation;
- related vehicle;
- affected part or system;
- remaining km/percent if relevant;
- read/unread indicator;
- action button or link.

## Severity Colors

- Informational: primaryLight/cyan.
- Warning: amber.
- Critical: critical red/pink.

## Implementation Notes

- Use `NotificationCard`.
- Do not spam users with repeated cards.
- Tapping a notification should navigate to the related part, dashboard, or recommendation screen if route exists.
- The notification details screen should reuse the same severity language and
  show the full message/recommended action.
- If notification backend is not ready, implement read-only local state or
  placeholder behind the same repository contract.
