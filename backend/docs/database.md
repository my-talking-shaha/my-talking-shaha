## Database schema

```mermaid
classDiagram
    direction LR

    class app_users {
        UUID id PK
        varchar email UK
        varchar username UK
        varchar password_hash
        varchar display_name
        varchar role
        boolean enabled
    }

    class vehicles {
        UUID id PK
        UUID owner_id FK
        varchar brand
        varchar model
        int production_year
        varchar color
        int mileage_km
        varchar fuel_type
        varchar engine_description
        varchar vin
        varchar photo_url
    }

    class parts {
        UUID id PK
        UUID vehicle_id FK
        varchar name
        varchar category
        date installed_at
        int installed_mileage_km
        int expected_lifetime_km
        int remaining_km
        int remaining_percent
        varchar status
        text description
        numeric cost
    }

    class part_photos {
        UUID part_id FK
        varchar photo_url
    }

    class timeline_events {
        UUID id PK
        UUID vehicle_id FK
        varchar type
        timestamptz event_date_time
    }

    class trips {
        UUID id PK_FK
        int start_mileage_km
        int end_mileage_km
        text route
        int duration_minutes
    }

    class refuel {
        UUID id PK_FK
        numeric liters
        numeric cost
        int mileage_km
        varchar fuel_type
        varchar fuel_name
        varchar station_name
    }

    class maintenance {
        UUID id PK_FK
        varchar name
        text description
        int mileage_km
        numeric cost
    }

    class event_photos {
        UUID id PK
        UUID event_id FK
        varchar photo_url
    }

    class chat_sessions {
        UUID id PK
        UUID vehicle_id FK
        timestamptz created_at
    }

    class chat_messages {
        UUID id PK
        UUID session_id FK
        varchar role
        text text
        timestamptz created_at
    }

    %% Inheritance (JOINED): one timeline_events row + one subtype row
    timeline_events <|-- trips
    timeline_events <|-- refuel
    timeline_events <|-- maintenance

    %% Associations (foreign keys) with multiplicities
    app_users "1" --> "0..*" vehicles : owns
    vehicles "1" --> "0..*" parts : has
    vehicles "1" --> "0..*" timeline_events : logs
    vehicles "1" --> "0..*" chat_sessions : has
    parts "1" --> "0..*" part_photos : has
    timeline_events "1" --> "0..*" event_photos : has
    chat_sessions "1" --> "0..*" chat_messages : contains
```

## Description

The schema is centred on **`vehicles`**: a `user` owns many vehicles, and everything else
hangs off a vehicle  its installed `parts`, its service-history `timeline_events`, and its
`chat_sessions`. Photos (`part_photos`, `event_photos`) and `chat_messages` are child
collections of their owner.

Service-history events use **JOINED inheritance**: the shared fields (`vehicle_id`, `type`,
`event_date_time`) live in `timeline_events`, while each concrete kind - `trips`, `refuel`,
`maintenance` - keeps its own columns in a separate table whose `id` is both the primary key
and a foreign key back to the parent (`PK_FK`). One logical event is therefore stored as two
rows sharing the same `id`.

**Notation.** `A <|-- B` - B *is a* kind of A (inheritance). `A "1" --> "0..*" B` - a
foreign key: one A is referenced by many B. `PK` primary key, `FK` foreign key, `UK` unique,
`PK_FK` both at once.
