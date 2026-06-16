CREATE TABLE IF NOT EXISTS maintenance(
    id UUID PRIMARY KEY,
    description TEXT,
    cost NUMERIC(10,2) NOT NULL CHECK (cost >= 0),

    photo_url VARCHAR(500),

    CONSTRAINT fk_maintenance_event
    FOREIGN KEY (id)
    REFERENCES timeline_events(id)
)