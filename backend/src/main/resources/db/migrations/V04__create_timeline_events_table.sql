CREATE TABLE timeline_events (
    id UUID PRIMARY KEY,

    vehicle_id UUID NOT NULL,

    type VARCHAR(32) NOT NULL,

    event_date_time TIMESTAMPTZ NOT NULL,


    CONSTRAINT fk_timeline_vehicle
    FOREIGN KEY (vehicle_id)
    REFERENCES vehicles(id)
);