CREATE TABLE IF NOT EXISTS chat_sessions (
    id UUID PRIMARY KEY,

    vehicle_id UUID NOT NULL,

    created_at TIMESTAMPTZ NOT NULL,

    CONSTRAINT fk_chat_vehicle
    FOREIGN KEY (vehicle_id)
    REFERENCES vehicles(id)
);