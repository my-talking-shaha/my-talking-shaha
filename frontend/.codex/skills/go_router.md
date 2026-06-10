# GoRouter Skill

## Goal

Keep navigation predictable, typed where possible, and compatible with auth and per-vehicle flows.

## Route Map

Suggested route names and paths:

```text
splash             /splash
login              /auth/login
register           /auth/register
garage             /garage
addVehicle         /garage/add
vehicleDashboard   /vehicle/:vehicleId
vehicleHistory     /vehicle/:vehicleId/history
addHistoryEvent    /vehicle/:vehicleId/history/add
vehicleParts       /vehicle/:vehicleId/parts
vehicleAnalytics   /vehicle/:vehicleId/analytics
vehicleChat        /vehicle/:vehicleId/chat
notifications      /notifications
settings           /settings
```

## Rules

- Use `vehicleId` path parameter for vehicle-specific screens.
- Do not rely only on in-memory selected vehicle for deep routes.
- Auth redirect must avoid loops.
- Bottom navigation should preserve the selected vehicle context when inside a vehicle.
- Do not navigate from data/domain layers.
- Controllers can expose success events; screens decide navigation.

## Auth Redirects

Expected logic:
- unauthenticated user -> `/auth/login` except public auth/register routes;
- authenticated user on auth pages -> `/garage`;
- after logout -> `/auth/login`;
- if a route requires vehicle ID and vehicle is missing/deleted -> `/garage` with an error message.

## Error Cases

Handle:
- missing/invalid `vehicleId`;
- deleted vehicle;
- unauthorized session;
- route opened before garage data loaded.
