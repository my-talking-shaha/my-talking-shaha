package ru.talkingshaha.backend.chat.repository;

import java.util.List;
import java.util.UUID;
import org.springframework.data.jpa.repository.JpaRepository;
import ru.talkingshaha.backend.chat.model.ChatMessage;
import ru.talkingshaha.backend.chat.model.ChatSession;

public interface ChatMessageRepository extends JpaRepository<ChatMessage, UUID> {
    List<ChatMessage> findAllBySessionOrderByCreatedAtAsc(ChatSession session);
}