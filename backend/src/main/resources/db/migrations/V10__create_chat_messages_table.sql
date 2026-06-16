CREATE TABLE IF NOT EXISTS chat_messages (
    id UUID PRIMARY KEY,

    session_id UUID NOT NULL,

    role VARCHAR(20) NOT NULL,

    text TEXT NOT NULL,

    created_at TIMESTAMPTZ NOT NULL,

    CONSTRAINT fk_chat_message_session
    FOREIGN KEY (session_id)
    REFERENCES chat_sessions(id)
);