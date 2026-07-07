-- Email-based authentication (issue #1) removed the app_users.username column.
-- V01 had already been applied to existing databases, so it must not be mutated;
-- drop the column and its unique constraint here as a forward migration instead.
ALTER TABLE app_users DROP CONSTRAINT IF EXISTS uk_app_users_username;
ALTER TABLE app_users DROP COLUMN IF EXISTS username;
