CREATE TABLE IF NOT EXISTS vehicle_photos
(
    id           UUID PRIMARY KEY,
    vehicle_id   UUID         NOT NULL,
    file_name    VARCHAR(255) NOT NULL,
    content_type VARCHAR(64)  NOT NULL,
    created_at   TIMESTAMPTZ  NOT NULL,
    CONSTRAINT fk_vehicle_photos
        FOREIGN KEY (vehicle_id)
            REFERENCES vehicles (id)
);
