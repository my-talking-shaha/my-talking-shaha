# History refactor baseline

This document records the shipped behavior and palette that the presentation
refactor must preserve. The implementation and widget tests remain the source
of truth when a future document differs from the running app.

## Timeline behavior

- Events load for the route vehicle and are sorted newest-first, grouped by
  localized uppercase month and year.
- Search is case-insensitive and matches the title plus type-specific details:
  fuel type/amount, maintenance description/replaced parts, or trip route.
- `ALL`, `FUEL`/`CHARGE`, `REPAIRS`, and `TRIPS` filters apply immediately.
  Electric vehicles display `CHARGE`; other vehicles display `FUEL`.
- A left swipe reveals edit and delete actions. Edit opens the event route and
  the revealed actions close after returning. Delete always asks for
  confirmation, removes cached photos, refreshes the timeline and related
  summaries, and reports success or failure with a snackbar.
- The add button opens the add route. A returned event refreshes history,
  dashboard, analytics, garage mileage, vehicle mileage, and parts. When the
  screen was launched from chat, back returns to that vehicle's chat.
- Loading, load failure/retry, empty timeline, and empty filtered results keep
  their distinct states.

## Form behavior

- The add form starts on fuel/recharge unless a route-selected type is passed.
  The animated selector switches among fuel/recharge, maintenance, and trip;
  editing locks the existing type.
- Date selection is date then time. Cancelling either picker keeps the previous
  value. Forms remain vertically scrollable and keyboard-safe.
- All events require a title. Fuel/maintenance mileage cannot be below the
  known mileage; an edited event may retain its own original mileage. Trips
  require start at or above the allowed minimum and end at or above start.
- Fuel accepts decimal liters greater than zero and at most 100. Recharge uses
  kWh wording and accepts values greater than zero and at most 500. Stored cost
  is capped at 100,000. Trip duration must be a positive integer.
- Maintenance requires a work description; cost, replaced parts, and photos
  are optional. Native platforms support multiple horizontally scrolling
  photos, removal, lost-photo recovery, and cleanup of local removed files.
- Save disables while in progress. Success returns the created/updated event.
  Failure cleans newly persisted photos, stays on the form, and shows the
  localized save error. Editing preserves the id, timestamp, existing values,
  and remote photos.

## Palette

All explicit history colors are exposed by `presentation/colors.dart`:

- background `#0E1118`
- surface `#1C1F25`
- elevated surface `#232731`
- border `#2B303B`
- primary `#B8C3FF`
- primary soft `#141B30`
- primary pressed `#3F63C9`
- on-primary `#002388`
- primary text `#F4F7FF`
- secondary text `#9AA3B2`
- muted text `#6F7788`
- white `#FFFFFF`
- warning swipe action `#DCA249`
- destructive swipe action `#D4352F`
- error `#E85D75`
- transparent overlays `#00000000`

Opacity variants retain their original alpha values at their call sites.
