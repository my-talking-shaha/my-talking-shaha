# Design Overview

## Product Feeling

**My Talking Shaha** should look and feel like a dark digital cockpit for a living car twin.
The user should feel that the car is not just stored as a static profile, but represented as an intelligent technical companion with history, status, predictions, and a chat interface.

The uploaded design screens establish a consistent automotive intelligence style:

- dark midnight background;
- glass-like cards with subtle borders;
- bright electric-blue actions;
- cyan intelligence/data accents;
- amber maintenance warnings;
- red/pink critical alerts;
- large readable technical values;
- futuristic but practical dashboard composition.

## Main Screens in the Design

The design package contains screens for:

- login;
- registration;
- garage empty state;
- garage with cars;
- new car details form;
- vehicle dashboard;
- parts/maintenance forecast widget;
- history timeline;
- add maintenance record form;
- add refuel record form;
- add trip record form;
- analytics dashboard;
- chat empty state;
- chat with messages;
- chat with error/insufficient data state;
- notification center;
- settings.

## Navigation Model

The product is organized around a selected vehicle.

High-level flow:

```text
Auth -> Garage -> Vehicle Dashboard -> Bottom Navigation
```

Main navigation areas:

- Garage: user's cars and car selection;
- History: vehicle timeline;
- Chat: AI conversation with the selected car;
- Analytics: intelligence and expenses;
- Settings: account and preferences.

The bottom navigation in the mockups contains icon-based tabs. The active tab uses a light lavender/primary accent, while inactive tabs are gray.

## Layout Principles

1. **Glanceability first.** Important technical data must be visible quickly: mileage, engine, state, next service, recent warnings.
2. **Cards as modules.** Each major block should be a reusable card: car card, stat card, VIN card, maintenance forecast, event card, analytics card.
3. **One main action per screen.** Auth has login/register. Garage has add/select car. History has add record. Chat has send message.
4. **Dark surfaces, bright actions.** Avoid many competing bright elements. Use primary blue only for real actions and active states.
5. **Reusable parts widget.** The parts/maintenance forecast block is a shared feature widget used by dashboard and analytics.

## Design-to-Architecture Mapping

```text
Auth screens              -> features/auth
Garage screens            -> features/garage
Vehicle dashboard         -> features/vehicle
Parts forecast widget     -> features/parts
History timeline/forms    -> features/history
Analytics dashboard       -> features/analytics
Chat screens              -> features/chat
Notification center       -> features/notifications
Settings screen           -> features/settings
Shared visual primitives  -> core/widgets + app/theme
```

## Design Constraints for Implementation

- The app should not use generic Material defaults without customization.
- All screens should share one dark theme.
- All feature screens should use the same card, input, button, and section-header components.
- Long forms must be scrollable and keyboard-safe.
- Empty states must be designed, not left blank.
- Error states must use friendly copy and avoid technical exception messages.
- Analytics must not fake data if data is unavailable.
- AI chat must show `Not enough data to answer` when the backend/assistant cannot answer.

## MVP Design Scope

Required for the first interactive prototype:

- auth UI;
- garage UI;
- add car form UI;
- vehicle dashboard UI;
- reusable parts forecast card;
- history timeline UI;
- basic add event forms;
- chat UI with mock states;
- settings UI.

Can be simplified for later:

- full analytics charts;
- notification center;
- photo upload gallery;
- voice input;
- real 3D model generation;
- complex chart interactions.
