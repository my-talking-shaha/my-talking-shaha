CREATE TABLE IF NOT EXISTS refuel
(
    id UUID PRIMARY KEY,
    liters NUMERIC(10, 2) NOT NULL CHECK ( liters > 0 ),
    cost NUMERIC(10,2) NOT NULL CHECK (cost >= 0),

    mileage_km INTEGER NOT NULL CHECK (mileage_km >= 0),

    fuel_type VARCHAR(32) NOT NULL,
    fuel_name VARCHAR(32) NOT NULL,
    station_name VARCHAR(255) NOT NULL,

    CONSTRAINT fk_refuel_event
    FOREIGN KEY (id)
    REFERENCES timeline_events(id)
)