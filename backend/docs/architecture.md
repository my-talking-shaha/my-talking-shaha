# Backend architecture

## Current project structure

The project currently contains a Spring Boot skeleton:

```text
backend/
  src/main/java/ru/talkingshaha/backend/
    BackendApplication.java
    common/model/BaseEntity.java
    user/model/AppUser.java
    user/model/UserRole.java
    vehicle/model/Vehicle.java
    vehicle/model/FuelType.java
  src/main/resources/application.properties
  pom.xml
```

Current base decisions:

- main entity ids use `UUID`;
- JPA entities inherit from `BaseEntity`;
- database settings are configured through environment variables;
- `spring.jpa.hibernate.ddl-auto=validate`, so the database structure should be created by Flyway migrations;
- `open-in-view=false`, so services must prepare all data needed for API responses.

## API conventions

- API prefix: `/api/v1`.
- Data format: JSON.
- Money values: decimal number plus currency. For MVP, currency can be `RUB`.
- Mileage is stored and returned in kilometers.
- Real ids in the backend are UUID strings. API examples may use short ids such as `1111` for readability.
- Lists should support pagination when they can grow: timeline events, chat messages, and notifications.

## API errors

Common error format:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Request contains invalid fields",
  "fields": {
    "mileageKm": "Must be greater than previous mileage"
  }
}
```

Base error codes:

- `VALIDATION_ERROR`
- `AUTHENTICATION_REQUIRED`
- `ACCESS_DENIED`
- `NOT_FOUND`
- `CONFLICT`
- `INSUFFICIENT_DATA`
- `INTERNAL_ERROR`

## Authentication

MVP uses email and password authentication. After login, the client receives an access token and sends it in `Authorization: Bearer <token>`. Yandex ID is an extension for a later stage.

## Validation

General rules:

- a user can access only their own vehicles;
- mileage in new events cannot be lower than the already known vehicle mileage;
- event date and time must be valid;
- required fields are checked at DTO level;
- repair and maintenance cost can be `0` if the user does not know the price;
- for MVP, photo metadata or URLs should be stored instead of binary files in the main tables.

