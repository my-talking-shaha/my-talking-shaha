# API Layer Skill

## Goal

Keep backend communication isolated, typed, and contract-driven.

## Location

Network infrastructure:

```text
lib/core/network/
  api_client.dart
  api_config.dart
  api_exception.dart
  error_mapper.dart
```

Feature data layer:

```text
features/<feature>/data/
  dto/
  datasources/
  repositories/
  mappers/
```

## Rules

- Datasources call HTTP client.
- DTOs parse JSON.
- Repositories map DTOs to domain entities.
- Domain repositories define contracts.
- Presentation never sees DTOs or raw HTTP responses.
- API base URL must come from config/env, not hardcoded in feature code.

## Error Envelope

Assume backend error shape:

```json
{
  "code": "VALIDATION_ERROR",
  "message": "Validation failed",
  "details": {
    "field": "mileage",
    "reason": "Mileage cannot be lower than previous value"
  }
}
```

Map backend errors to domain/app failures:
- validation;
- unauthorized;
- not found;
- conflict;
- server;
- network/unavailable;
- unknown.

## Auth

- Attach bearer token in network layer.
- Do not attach tokens manually in every datasource.
- Handle `401` consistently.
- Never log tokens.

## Contract Changes

If implementation requires changing endpoint, field, or error behavior, update the matching `docs/contracts/*.md` file.
