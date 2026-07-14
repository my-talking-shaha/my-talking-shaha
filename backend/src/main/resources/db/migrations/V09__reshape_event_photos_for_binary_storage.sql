DELETE FROM event_photos;

ALTER TABLE event_photos DROP COLUMN photo_url;
ALTER TABLE event_photos ADD COLUMN file_name    VARCHAR(255) NOT NULL;
ALTER TABLE event_photos ADD COLUMN content_type VARCHAR(64)  NOT NULL;
ALTER TABLE event_photos ADD COLUMN created_at   TIMESTAMPTZ  NOT NULL;
