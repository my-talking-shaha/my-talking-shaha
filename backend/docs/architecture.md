# Backend architecture

## Current project structure

The project currently contains a Spring Boot skeleton:

```text
backend/
  src/main/java/ru/talkingshaha/backend/
    BackendApplication.java
    common/
      dto/
      error/
      model/
    user/
      model/
    vehicle/
      dto/
      model/
    part/
      model/
    timeline/
      model/
    chat/
      dto/
      model/
    prediction/
      dto/
      service/
  src/main/resources/application.properties
  pom.xml
```

Current base decisions:

- main entity ids use `UUID`;
- JPA entities inherit from `BaseEntity`;
- DTO classes are separate from JPA entities;
- JPA entity drafts for chat, timeline, and vehicle parts are left for the database/schema task;
- repositories and migrations are intentionally not included in this part of Week 2 work;
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
- `EMAIL_ALREADY_EXISTS`
- `INVALID_CREDENTIALS`
- `INSUFFICIENT_DATA`
- `INTERNAL_ERROR`

## Authentication

MVP uses email and password authentication.

Endpoints (`/api/v1/auth`):

- `POST /register` — create an account from `email`, `password`, and `displayName`. Returns `201` with the user and a token pair. The user is signed in automatically; the garage starts empty (vehicles are owned per user, no separate garage entity).
- `POST /login` — authenticate by `email` and `password`. Returns `200` with the user and a token pair.
- `POST /refresh` — exchange a valid refresh token for a new token pair. The presented refresh token is rotated out (single use).
- `POST /logout` — invalidate the supplied refresh token. Returns `204`.

Tokens: register and login return a short-lived **access token** (JWT, sent as `Authorization: Bearer <token>`) and a longer-lived **refresh token** (stored server-side and revoked on logout/rotation).

Passwords are stored as BCrypt hashes. A valid password is 6–72 characters and may contain letters (a-z, A-Z), digits, and the special characters `()[]$#*-_?!.%+<>/`.

Auth error codes:

- `400 VALIDATION_ERROR` — invalid request fields (including password rules);
- `409 EMAIL_ALREADY_EXISTS` — email already registered;
- `401 INVALID_CREDENTIALS` — wrong email/password, or invalid/expired refresh token.

Yandex ID is an extension for a later stage.

## Validation

General rules:

- a user can access only their own vehicles;
- mileage in new events cannot be lower than the already known vehicle mileage;
- event date and time must be valid;
- required fields are checked at DTO level;
- repair and maintenance cost must be greater than `0`;
- for MVP, photo metadata or URLs should be stored instead of binary files in the main tables.
