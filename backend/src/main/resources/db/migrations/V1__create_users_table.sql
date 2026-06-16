CREATE TABLE IF NOT EXISTS app_users(
    id UUID PRIMARY KEY,

    email VARCHAR(255) NOT NULL UNIQUE,

    username VARCHAR(50) NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    display_name VARCHAR(120) NOT NULL,

    role VARCHAR(32) NOT NULL,
    enabled BOOLEAN NOT NULL DEFAULT TRUE,

    CONSTRAINT uk_app_users_username UNIQUE (username)
   );
