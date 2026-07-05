ALTER TABLE trips
    ALTER COLUMN end_mileage_km DROP NOT NULL;

ALTER TABLE trips
    ALTER COLUMN duration_minutes DROP NOT NULL;

ALTER TABLE trips
    ADD COLUMN IF NOT EXISTS distance_km INTEGER CHECK (distance_km >= 0),
    ADD COLUMN IF NOT EXISTS ended_at TIMESTAMPTZ,
    ADD COLUMN IF NOT EXISTS fuel_liters NUMERIC(10, 2) CHECK (fuel_liters > 0),
    ADD COLUMN IF NOT EXISTS notes TEXT,
    ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'COMPLETE',
    ADD COLUMN IF NOT EXISTS chat_session_id UUID;

ALTER TABLE trips
    ADD CONSTRAINT fk_trip_chat_session
        FOREIGN KEY (chat_session_id)
            REFERENCES chat_sessions (id);

UPDATE trips
SET distance_km = end_mileage_km - start_mileage_km
WHERE distance_km IS NULL
  AND start_mileage_km IS NOT NULL
  AND end_mileage_km IS NOT NULL;