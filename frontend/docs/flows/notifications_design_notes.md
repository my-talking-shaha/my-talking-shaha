# Notifications Design Notes

## Screen From Design

- `Notofications-notification_center.jpg`

## Visual Structure

The notifications center shows warning and recommendation cards related to vehicle condition and parts lifetime.

Screen structure:
- top app bar/title;
- list of notification cards;
- severity indicators;
- time/date;
- recommended action;
- optional CTA to open part/details.

## Notification Card Content

Each notification may display:
- severity icon;
- title;
- short explanation;
- affected part or system;
- remaining km/percent if relevant;
- action button or link.

## Severity Colors

- Informational: primaryLight/cyan.
- Warning: amber.
- Critical: critical red/pink.

## Implementation Notes

- Use `NotificationCard`.
- Do not spam users with repeated cards.
- Tapping a notification should navigate to the related part, dashboard, or recommendation screen if route exists.
- If notification backend is not ready, implement read-only mock state or placeholder.
