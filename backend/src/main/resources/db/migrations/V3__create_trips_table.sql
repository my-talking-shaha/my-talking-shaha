CREATE TABLE trips
(
    id UUID PRIMARY KEY,

    start_mileage_km INT NOT NULL CHECK (start_mileage_km >=0),
    end_mileage_km INT NOT NULL CHECK (end_mileage_km >= start_mileage_km),

    route TEXT NOT NULL,

    duration_minutes INT NOT NULL CHECK (duration_minutes >0),
    cost NUMERIC(10,2) NOT NULL CHECK (cost >= 0),

    CONSTRAINT fk_trip_event
    FOREIGN KEY (id)
    REFERENCES timeline_events(id)

);