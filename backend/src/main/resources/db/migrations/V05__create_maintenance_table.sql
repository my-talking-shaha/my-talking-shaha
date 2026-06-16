CREATE TABLE IF NOT EXISTS maintenance(
    id UUID PRIMARY KEY,
    description TEXT,

    mileage_km INTEGER NOT NULL CHECK (mileage_km >= 0),

    cost NUMERIC(10,2) NOT NULL CHECK (cost >= 0),

    CONSTRAINT fk_maintenance_event
    FOREIGN KEY (id)
    REFERENCES timeline_events(id)
)