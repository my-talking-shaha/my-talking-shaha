CREATE TABLE IF NOT EXISTS vehicles{
    id UUID PRIMARY KEY,
    owner_id UUID NOT NULL,
    brand VARCHAR (80) NOT NULL,
    model VARCHAR (120) NOT NULL,

    production_year INTEGER NOT NULL CHECK (production_year<2100 AND production_year>1886),
    color VARCHAR(40),

    mileage_km INTEGER NOT NULL CHECK (mileage_km>=0) DEFAULT 0,

    fuel_type VARCHAR(32),
    engine_description VARCHAR(80),

    vin VARCHAR(32),
    photo_url VARCHAR(500),

    CONSTRAINT fk_vehicle_owner
    FOREIGN KEY (owner_id)
    REFERENCES app_users(id)

    }
