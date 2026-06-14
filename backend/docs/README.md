# Backend documentation

## What the backend does

The backend stores user accounts, garage vehicles, car history, parts, analytics, maintenance predictions, and AI chat history. The mobile application uses the backend as the main data source for these screens:

- authentication and profile;
- garage and vehicle dashboard;
- vehicle chat as the main start screen;
- trip, refuel, repair, and maintenance history;
- expense, mileage, and maintenance analytics;
- part lifetime prediction and warnings.

## Current technical stack

- Java 21
- Spring Boot
- Maven
- Spring Web
- Spring Data JPA
- PostgreSQL
- Flyway
- Actuator
- Lombok

## Documents

- [architecture.md](architecture.md) - backend architecture, API rules, validation rules, and error format.
- [api-contract.md](api-contract.md) - one API contract for the mobile application.
- [prediction.md](prediction.md) - how the backend supports the AI chat, quick questions, intent flow, and maintenance prediction.

## MVP

The MVP foundation includes:

- registration and login with email and password;
- user garage with multiple vehicles;
- dashboard for the selected vehicle;
- manual history input: trips, refuels, repairs, and maintenance;
- parts list and rule-based remaining lifetime calculation;
- chat that answers using vehicle data and can redirect the user to a form;
- aggregated analytics for mobile screens;
- push notifications.

Yandex ID, voice input, 3D model generation, and external car catalogs are planned as extensions after the basic MVP.

