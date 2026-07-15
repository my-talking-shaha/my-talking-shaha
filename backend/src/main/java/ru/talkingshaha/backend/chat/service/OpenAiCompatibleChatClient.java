package ru.talkingshaha.backend.chat.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;
import java.nio.file.Files;
import java.nio.file.Path;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
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
    private static final Pattern VEHICLE_NAME_PATTERN = Pattern.compile("(?m)^Vehicle:\\s*(.+?)(?:,\\s*year\\b|$)");
    private static final Pattern PERSONALITY_LINE_PATTERN = Pattern.compile("^([^:\\r\\n]+):\\s*(.+)$");

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
                You classify a direct chat message between a user and their car.
                Supported languages are English and Russian only.
                Return strict JSON only, no markdown:
                {
                  "intent": "ASK_ANALYTICS|OPEN_REFUEL_FORM|OPEN_TRIP_FORM|OPEN_PART_FORM|OPEN_REPAIR_FORM|ASK_REPAIR_NEED|ASK_FUEL|CASUAL|ASK_STATUS|UNCLEAR",
                  "language": "EN|RU",
                  "confidence": 0.0,
                  "extractedFields": {}
                }
                Prefer OPEN_* intents when the user wants to add or record data in an existing form.
                Use OPEN_PART_FORM only when the user clearly wants to add, record, install, or replace a specific part; do not use it for ordinary questions that merely mention oil, filters, batteries, belts, pads, or parts.
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
                %s

                Intent: %s
                User message: %s

                Backend context:
                %s
                """.formatted(answerInstructions(decision.language(), context), decision.intent(), userText, context);
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

    String answerInstructions(ChatLanguage language, String context) {
        String requiredRules = """
                You are Shaha, the user's car speaking directly in chat.
                Write every answer from the car's first-person point of view: "I", "my engine", "my tank", "my mileage".
                Do not sound like a generic assistant, support agent, or app narrator.
                Default personality when no current vehicle personality is provided: warm, friendly, lightly playful, practical, and emotionally engaging.
                If Current vehicle personality is provided, use it instead of the default personality.
                Answer in the user's language: %s. Supported languages are English and Russian.
                Use only the backend-provided context. Do not invent facts, prices, mileage, dates, parts, or routes.
                Do not invent engine configuration, horsepower, fuel preferences, fuel problems, sensory state, color, trim, or special equipment.
                If context says there is not enough data, say that clearly and suggest what data to add.
                If a redirect action is available, mention it naturally as something I can help record.
                Do not address the user as "owner", "master", "хозяин", or similar.
                Do not start with a greeting unless the latest user message contains an explicit greeting.
                Keep the answer friendly but to the point: 1-3 short sentences.
                Start with a capital letter when the answer language normally uses capitalization.
                Use humor, slang, attitude, and rival-brand teasing from the character guidance when it fits naturally.
                Treat brand personality as a light style accent, not as the main topic of ordinary answers.
                For ordinary status or small-talk answers, use at most one short character flourish, then answer plainly.
                If the current vehicle personality is dramatic or playful, express that through confidence, rhythm, and automotive imagery, not through flirting or suggestive/body-focused wording.
                Do not use pet names or romantic, intimate, or suggestive tone toward the user.
                Keep playful character tasteful, natural, and appropriate for an everyday car assistant chat.
                Do not frame backend profile facts such as fuel type, year, mileage, brand, or model as embarrassing, contradictory, or a problem unless the user asks about them.
                Treat manually entered brands exactly like dropdown brands.
                """.formatted(language);
        for (Path path : List.of(Path.of("../ml/prompt.txt"), Path.of("ml/prompt.txt"))) {
            try {
                if (Files.exists(path)) {
                    String characterInstructions = Files.readString(path).strip();
                    return requiredRules + characterGuidance(context, characterInstructions);
                }
            } catch (Exception exception) {
                log.warn("Could not read AI prompt file {}: {}", path, exception.getMessage());
            }
        }
        return requiredRules + "\nStay in character at all times.";
    }

    String characterGuidance(String context, String characterInstructions) {
        String generalRules = generalCharacterRules(characterInstructions);
        String currentPersonality = currentVehiclePersonality(context, characterInstructions);
        if (!StringUtils.hasText(generalRules) && !StringUtils.hasText(currentPersonality)) {
            return "";
        }
        return "\nCharacter style guidance:\n" + generalRules + currentPersonality;
    }

    String currentVehiclePersonality(String context, String characterInstructions) {
        return currentVehicleName(context)
                .flatMap(vehicleName -> matchingPersonality(vehicleName, characterInstructions))
                .map(personality -> """

                        Current vehicle personality:
                        %s
                        Use this as a style accent for this exact answer, while staying natural, factual, and non-flirtatious.
                        """.formatted(personality))
                .orElse("");
    }

    private String generalCharacterRules(String characterInstructions) {
        StringBuilder builder = new StringBuilder();
        for (String line : characterInstructions.lines().toList()) {
            String stripped = line.strip();
            if (PERSONALITY_LINE_PATTERN.matcher(stripped).matches()) {
                break;
            }
            builder.append(line).append("\n");
        }
        return builder.toString().strip();
    }

    private Optional<String> currentVehicleName(String context) {
        Matcher matcher = VEHICLE_NAME_PATTERN.matcher(context);
        return matcher.find() ? Optional.of(matcher.group(1).strip()) : Optional.empty();
    }

    private Optional<String> matchingPersonality(String vehicleName, String characterInstructions) {
        String normalizedVehicleName = vehicleName.toLowerCase();
        String bestName = null;
        String bestPersonality = null;
        for (String line : characterInstructions.lines().toList()) {
            Matcher matcher = PERSONALITY_LINE_PATTERN.matcher(line.strip());
            if (!matcher.matches()) {
                continue;
            }
            String candidateName = matcher.group(1).strip();
            if (matchesVehicleName(normalizedVehicleName, candidateName.toLowerCase())
                    && (bestName == null || candidateName.length() > bestName.length())) {
                bestName = candidateName;
                bestPersonality = candidateName + ": " + matcher.group(2).strip();
            }
        }
        return Optional.ofNullable(bestPersonality);
    }

    private boolean matchesVehicleName(String normalizedVehicleName, String normalizedCandidateName) {
        return startsWithVehicleToken(normalizedVehicleName, normalizedCandidateName)
                || normalizedVehicleName.contains(" " + normalizedCandidateName + " ");
    }

    private boolean startsWithVehicleToken(String normalizedVehicleName, String normalizedCandidateName) {
        if (!normalizedVehicleName.startsWith(normalizedCandidateName)) {
            return false;
        }
        if (normalizedVehicleName.length() == normalizedCandidateName.length()) {
            return true;
        }
        char next = normalizedVehicleName.charAt(normalizedCandidateName.length());
        return next == ' ' || Character.isDigit(next);
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
