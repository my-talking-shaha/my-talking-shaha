CREATE TABLE IF NOT EXISTS parts(
    id UUID PRIMARY KEY,

    name VARCHAR (255) NOT NULL ,
    category VARCHAR (50) NOT NULL,

    installedAt DATE NOT NULL,

    installed_mileage_km INT NOT NULL CHECK ( installed_mileage_km > 0 ),
    expected_lifetime_km INT NOT NULL CHECK ( expected_lifetime_km > 0 ),

    remaining_km INT NOT NULL CHECK ( remaining_km > 0 ),
    remaining_percent INT NOT NULL CHECK ( remaining_percent > 0 ) DEFAULT 100,
    status VARCHAR(20) NOT NULL
)