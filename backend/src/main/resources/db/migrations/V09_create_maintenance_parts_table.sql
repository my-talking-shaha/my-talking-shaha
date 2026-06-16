CREATE TABLE maintenance_parts (
    id UUID PRIMARY KEY,

    maintenance_id UUID NOT NULL,

    name VARCHAR(255) NOT NULL,

    expected_lifetime_km INTEGER CHECK (expected_lifetime_km > 0),

    CONSTRAINT fk_maintenance_parts
       FOREIGN KEY (maintenance_id)
           REFERENCES maintenance(id)
);