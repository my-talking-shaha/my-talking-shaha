CREATE TABLE timeline_events (
    id UUID PRIMARY KEY,

    vehicle_id UUID NOT NULL,

    type VARCHAR(32) NOT NULL,

    event_date_time TIMESTAMP NOT NULL,

    title VARCHAR(255) NOT NULL,


    currency VARCHAR(3),

    CONSTRAINT fk_timeline_vehicle
    FOREIGN KEY (vehicle_id)
    REFERENCES vehicles(id)
);