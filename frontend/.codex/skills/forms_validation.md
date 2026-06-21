# Forms and Validation Skill

## Goal

Keep user input predictable, validated, and consistent with acceptance criteria.

## General Rules

- Validate before submit.
- Show field-level errors when possible.
- Prevent duplicate submissions while loading.
- Trim text fields where appropriate.
- Preserve user input after failed submit.
- Map backend validation errors to fields when possible.

## Auth

Registration:
- email is required;
- password is required;
- password min length: 6 characters;
- existing email conflict shows understandable error;
- after success, user enters app and empty garage exists.

Login:
- email is required;
- password is required;
- invalid credentials show understandable error.

## Vehicle Form

Required:
- brand;
- model;
- year;
- current mileage;
- engine type.
- engine specification: volume or power output based on engine type.

Optional:
- color.
- VIN.

Validation:
- year must be realistic;
- mileage must be non-negative;
- engine specification must be positive;
- volume and power output are mutually exclusive;
- VIN must contain exactly 17 characters when provided;
- brand/model may come from catalog or manual input;
- no submit while already submitting.

## History Event Forms

All event types:
- date is required;
- mileage is required where applicable;
- new mileage cannot be lower than previous known mileage;
- cost cannot be negative.

Repair:
- description required;
- replaced parts required;
- photos optional.

Refueling:
- liters required and positive;
- fuel type required;
- cost required and non-negative.

Trip:
- start mileage required;
- end mileage required;
- end mileage must be >= start mileage;
- route optional.

Maintenance:
- description/service type required;
- cost required and non-negative.

## Parts

Required:
- part name;
- installedAt date;
- installedAtMileage.

Optional:
- lifetimeKm.

Validation:
- installedAtMileage cannot be negative;
- lifetimeKm must be positive when provided;
- replacement action must create or link a new timeline event if backend supports it.

## Chat

- Message cannot be empty after trim.
- Message should have reasonable max length.
- Disable send while message is submitting unless queueing is explicitly implemented.
- If AI cannot answer, show exact fallback from contract.
