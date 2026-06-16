CREATE TABLE event_photos (
    id UUID PRIMARY KEY,

    event_id UUID NOT NULL,

    photo_url VARCHAR(500) NOT NULL,

    CONSTRAINT fk_event_photos
      FOREIGN KEY (event_id)
          REFERENCES timeline_events(id)
);