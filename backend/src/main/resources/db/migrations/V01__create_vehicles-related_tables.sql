CREATE TABLE IF NOT EXISTS app_users
(
    id            UUID PRIMARY KEY,
    email         VARCHAR(255) NOT NULL UNIQUE,
    username      VARCHAR(50)  NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name  VARCHAR(120) NOT NULL,
    role          VARCHAR(32)  NOT NULL,
    enabled       BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT uk_app_users_username UNIQUE (username)

);

CREATE TABLE IF NOT EXISTS vehicles
(
    id                 UUID PRIMARY KEY,
    owner_id           UUID         NOT NULL,
    brand              VARCHAR(80)  NOT NULL,
    model              VARCHAR(120) NOT NULL,
    production_year    INTEGER      NOT NULL CHECK (production_year >= 1900 AND production_year <= 2100),
    color              VARCHAR(40),
    mileage_km         INTEGER      NOT NULL CHECK (mileage_km >= 0) DEFAULT 0,
    fuel_type          VARCHAR(32),
    engine_description VARCHAR(80),
    vin                VARCHAR(17),
    photo_url          VARCHAR(500),
    CONSTRAINT fk_vehicle_owner
    FOREIGN KEY (owner_id)
    REFERENCES app_users (id)
);

CREATE TABLE IF NOT EXISTS timeline_events
(
    id              UUID PRIMARY KEY,
    vehicle_id      UUID        NOT NULL,
    type            VARCHAR(32) NOT NULL,
    event_date_time TIMESTAMPTZ NOT NULL,
    CONSTRAINT fk_timeline_vehicle
        FOREIGN KEY (vehicle_id)
            REFERENCES vehicles (id)
);

CREATE TABLE IF NOT EXISTS trips
(
    id               UUID PRIMARY KEY,
    start_mileage_km INT CHECK (start_mileage_km >= 0),
    end_mileage_km   INT NOT NULL CHECK (end_mileage_km >= 0 and end_mileage_km >= start_mileage_km),
    route            TEXT,
    duration_minutes INT NOT NULL CHECK (duration_minutes > 0),
    CONSTRAINT fk_trip_event
        FOREIGN KEY (id)
            REFERENCES timeline_events (id)
);

CREATE TABLE IF NOT EXISTS maintenance
(
    id          UUID PRIMARY KEY,
    name        VARCHAR(255)   NOT NULL,
    description TEXT,
    mileage_km  INTEGER        NOT NULL CHECK (mileage_km >= 0),
    cost        NUMERIC(10, 2) CHECK (cost > 0),
    CONSTRAINT fk_maintenance_event
        FOREIGN KEY (id)
            REFERENCES timeline_events (id)
);

CREATE TABLE IF NOT EXISTS refuel
(
    id           UUID PRIMARY KEY,
    liters       NUMERIC(10, 2) NOT NULL CHECK ( liters > 0 ),
    cost         NUMERIC(10, 2) NOT NULL CHECK (cost > 0),
    mileage_km   INTEGER        NOT NULL CHECK (mileage_km >= 0),
    fuel_type    VARCHAR(32)    NOT NULL,
    fuel_name    VARCHAR(32),
    station_name VARCHAR(255),
    CONSTRAINT fk_refuel_event
        FOREIGN KEY (id)
            REFERENCES timeline_events (id)
);

CREATE TABLE IF NOT EXISTS parts
(
    id                   UUID PRIMARY KEY,
    vehicle_id           UUID         NOT NULL,
    name                 VARCHAR(255) NOT NULL,
    category             VARCHAR(50)  NOT NULL,
    installed_at         DATE         NOT NULL,
    installed_mileage_km INT          NOT NULL CHECK ( installed_mileage_km >= 0 ),
    expected_lifetime_km INT CHECK ( expected_lifetime_km > 0 ),
    remaining_km         INT,
    remaining_percent    INT,
    status               VARCHAR(20)  NOT NULL,
    description          TEXT,
    cost                 NUMERIC(10, 2) CHECK (cost > 0),
    CONSTRAINT fk_vehicle_parts
        FOREIGN KEY (vehicle_id)
            REFERENCES vehicles (id)
);

CREATE TABLE IF NOT EXISTS event_photos
(
    id        UUID PRIMARY KEY,
    event_id  UUID         NOT NULL,
    photo_url VARCHAR(500) NOT NULL,
    CONSTRAINT fk_event_photos
        FOREIGN KEY (event_id)
            REFERENCES timeline_events (id)
);

CREATE TABLE IF NOT EXISTS part_photos
(
    part_id   UUID         NOT NULL,
    photo_url VARCHAR(500) NOT NULL,
    CONSTRAINT fk_part_photos
        FOREIGN KEY (part_id)
            REFERENCES parts (id)
);

