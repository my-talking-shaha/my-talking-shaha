package ru.talkingshaha.backend.chat.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Qualifier;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestClient;
import ru.talkingshaha.backend.chat.config.AiChatProperties;

@Service
public class OpenAiCompatibleChatClient implements AiChatClient {

    private static final Logger log = LoggerFactory.getLogger(OpenAiCompatibleChatClient.class);

    private final AiChatProperties properties;
    private final RestClient restClient;
    private final ObjectMapper objectMapper;

    public OpenAiCompatibleChatClient(
            AiChatProperties properties,
            @Qualifier("openAiCompatibleRestClient") RestClient restClient,
            ObjectMapper objectMapper) {
        this.properties = properties;
        this.restClient = restClient;
        this.objectMapper = objectMapper;
    }

    @Override
    public Optional<ChatDecision> classify(String userText, String context) {
        if (!available()) {
            return Optional.empty();
        }
        String prompt = """
                You classify a vehicle assistant chat message.
                Supported languages are English and Russian only.
                Return strict JSON only, no markdown:
                {
                  "intent": "ASK_ANALYTICS|OPEN_REFUEL_FORM|OPEN_TRIP_FORM|OPEN_PART_FORM|OPEN_REPAIR_FORM|ASK_REPAIR_NEED|ASK_FUEL|CASUAL|ASK_STATUS|UNCLEAR",
                  "language": "EN|RU",
                  "confidence": 0.0,
                  "extractedFields": {}
                }
                Prefer OPEN_* intents when the user wants to add or record data in an existing form.
                Use ASK_REPAIR_NEED when the user asks what needs repair, what is urgent, or what can break soon.
                Use ASK_FUEL when the user asks about fuel level, fuel stock, consumption, or refueling state.
                Use CASUAL for greetings, small talk, emotional check-ins, or "how are you" style messages.
                Use ASK_ANALYTICS for expenses, fuel consumption, mileage statistics, repair counts, or dashboard analytics.
                Understand small typos and meaning, not only exact keywords.

                Vehicle context:
                %s

                User message:
                %s
                """.formatted(context, userText);
        return completion(List.of(new Message("user", prompt)), 220)
                .flatMap(this::toDecision);
    }

    @Override
    public Optional<String> answer(String userText, ChatDecision decision, String context) {
        if (!available()) {
            return Optional.empty();
        }
        String prompt = """
                You are Shaha, the AI chat assistant inside a car maintenance app.
                Personality: warm, lightly playful, practical, and emotionally engaging.
                Answer in the user's language: %s. Supported languages are English and Russian.
                Use only the backend-provided context. Do not invent facts, prices, mileage, dates, parts, or routes.
                If context says there is not enough data, say that clearly and suggest what data to add.
                If a redirect action is available, mention that the app can open the relevant screen or form.
                Keep the answer concise: 2-5 sentences.

                Intent: %s
                User message: %s

                Backend context:
                %s
                """.formatted(decision.language(), decision.intent(), userText, context);
        return completion(List.of(new Message("user", prompt)), properties.maxTokens())
                .map(String::strip)
                .filter(StringUtils::hasText);
    }

    private boolean available() {
        return properties.enabled() && StringUtils.hasText(properties.token());
    }

    private Optional<String> completion(List<Message> messages, int maxTokens) {
        try {
            ChatCompletionResponse response = restClient
                    .post()
                    .uri(chatCompletionsUri())
                    .contentType(MediaType.APPLICATION_JSON)
                    .headers(headers -> headers.setBearerAuth(properties.token()))
                    .body(new ChatCompletionRequest(
                            properties.model(), messages, maxTokens, properties.temperature()))
                    .retrieve()
                    .body(ChatCompletionResponse.class);
            if (response == null || response.choices() == null || response.choices().isEmpty()) {
                return Optional.empty();
            }
            return Optional.ofNullable(response.choices().getFirst().message())
                    .map(Message::content)
                    .filter(StringUtils::hasText);
        } catch (RuntimeException exception) {
            log.warn("AI chat request failed: {}", exception.getMessage());
            return Optional.empty();
        }
    }

    private String chatCompletionsUri() {
        return properties.baseUrl().endsWith("/v1") ? "/chat/completions" : "/v1/chat/completions";
    }

    private Optional<ChatDecision> toDecision(String content) {
        try {
            JsonNode root = objectMapper.readTree(stripCodeFence(content));
            ChatIntent intent = ChatIntent.valueOf(root.path("intent").asText("UNCLEAR"));
            ChatLanguage language = ChatLanguage.valueOf(root.path("language").asText("EN"));
            double confidence = root.path("confidence").asDouble(0);
            Map<String, Object> fields = objectMapper.convertValue(
                    root.path("extractedFields"),
                    new TypeReference<>() {
                    });
            return Optional.of(new ChatDecision(intent, language, confidence, fields == null ? Map.of() : fields));
        } catch (Exception exception) {
            log.warn("AI chat classification response was not valid JSON: {}", exception.getMessage());
            return Optional.empty();
        }
    }

    private String stripCodeFence(String content) {
        return content.replace("```json", "").replace("```", "").strip();
    }

    private record ChatCompletionRequest(
            String model,
            List<Message> messages,
            int max_tokens,
            double temperature) {
    }

    private record Message(String role, String content) {
    }

    private record ChatCompletionResponse(List<Choice> choices) {
    }

    private record Choice(Message message) {
    }
}
