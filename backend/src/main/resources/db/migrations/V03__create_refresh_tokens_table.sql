CREATE TABLE IF NOT EXISTS refresh_tokens
(
    id         UUID PRIMARY KEY,
    user_id    UUID         NOT NULL,
    token      VARCHAR(512) NOT NULL,
    expires_at TIMESTAMPTZ  NOT NULL,
    CONSTRAINT uk_refresh_tokens_token UNIQUE (token),
    CONSTRAINT fk_refresh_tokens_user
        FOREIGN KEY (user_id) REFERENCES app_users (id) ON DELETE CASCADE
);