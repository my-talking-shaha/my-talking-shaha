# Garage Design Notes

## Screens From Design

- Accord to `docs/design/screenshots/garage/` for design example

## Garage With Cars

The garage screen is a car park overview.

Visual structure:
- large brand title at top;
- section label `YOUR GARAGE`;
- screen title `Garage`;
- circular add button near the top right;
- vertical list of large vehicle cards;
- bottom navigation.

Vehicle card content:
- large car image;
- car name, e.g. `Lada 2106`;
- subtitle/personality label;
- quick metrics such as mileage, last repair, last refuel;
- primary CTA `Open cockpit` with arrow.

## Empty Garage

Empty state visual structure:
- app title;
- centered assistant/car icon;
- text explaining that the garage is empty;
- primary button `Add vehicle`;
- bottom navigation.

## Add Car Details Form

The form screen uses:
- top bar with back arrow;
- title `Car Specifications` / car details;
- dark input fields;
- grouped fields for brand/model/year/color/engine/mileage;
- primary save/add button.

## Implementation Notes

- Use `VehicleGarageCard` for each vehicle.
- Use `GarageEmptyState` when list is empty.
- Add car form should use shared form components.
- Do not implement catalog search unless backend/contracts are ready; allow manual input first.
- Vehicle image should use uploaded image if present, otherwise fallback asset.
