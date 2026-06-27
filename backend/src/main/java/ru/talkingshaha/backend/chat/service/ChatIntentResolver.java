package ru.talkingshaha.backend.chat.service;

import java.text.Normalizer;
import java.util.List;
import java.util.Locale;
import java.util.Map;
import org.springframework.stereotype.Service;

@Service
public class ChatIntentResolver {

    private static final double AI_CONFIDENCE_THRESHOLD = 0.55;

    private final AiChatClient aiChatClient;

    public ChatIntentResolver(AiChatClient aiChatClient) {
        this.aiChatClient = aiChatClient;
    }

    public ChatDecision resolve(String userText, String context) {
        ChatLanguage language = detectLanguage(userText);
        return aiChatClient.classify(userText, context)
                .filter(decision -> decision.confidence() >= AI_CONFIDENCE_THRESHOLD)
                .orElseGet(() -> localResolve(userText, language));
    }

    private ChatDecision localResolve(String userText, ChatLanguage language) {
        String text = normalize(userText);
        if (matches(text, "fuel", "refuel", "gas", "petrol", "заправ", "бенз", "топлив", "залил", "бак")) {
            return decision(ChatIntent.OPEN_REFUEL_FORM, language);
        }
        if (matches(text, "trip", "drive", "drove", "route", "поезд", "маршрут", "ехал", "проех", "дорог")) {
            return decision(ChatIntent.OPEN_TRIP_FORM, language);
        }
        if (matches(text, "urgent", "soon", "break soon", "condition", "maintenance", "forecast", "repair need",
                "сроч", "состоя", "сломается", "сломаться", "то", "обслуж", "прогноз", "починить")) {
            return decision(ChatIntent.ASK_REPAIR_NEED, language);
        }
        if (matches(text, "changed", "replace", "part", "oil", "filter", "pads", "belt", "battery",
                "замен", "детал", "масл", "фильтр", "колод", "ремен", "аккумулятор")) {
            return decision(ChatIntent.OPEN_PART_FORM, language);
        }
        if (matches(text, "add repair", "record repair", "new repair", "repair record",
                "добавить ремонт", "записать ремонт", "новый ремонт", "запись ремонта")) {
            return decision(ChatIntent.OPEN_REPAIR_FORM, language);
        }
        if (matches(text, "expense", "cost", "spent", "analytics", "statistics", "consumption", "mileage",
                "расход", "потрат", "стоим", "статист", "аналит", "пробег")) {
            return decision(ChatIntent.ASK_ANALYTICS, language);
        }
        if (matches(text, "status", "car", "vehicle", "how is", "машин", "авто", "как дела")) {
            return decision(ChatIntent.ASK_STATUS, language);
        }
        return ChatDecision.unclear(language);
    }

    private ChatDecision decision(ChatIntent intent, ChatLanguage language) {
        return new ChatDecision(intent, language, 0.75, Map.of());
    }

    private boolean matches(String text, String... phrases) {
        return List.of(phrases).stream().anyMatch(phrase -> containsPhrase(text, normalize(phrase)));
    }

    private boolean containsPhrase(String text, String phrase) {
        if (text.contains(phrase)) {
            return true;
        }
        return List.of(text.split("\\s+")).stream().anyMatch(word -> similar(word, phrase));
    }

    private boolean similar(String word, String phrase) {
        if (word.length() < 4 || phrase.length() < 4) {
            return false;
        }
        int distance = editDistance(word, phrase);
        return distance <= (Math.max(word.length(), phrase.length()) <= 6 ? 1 : 2);
    }

    private int editDistance(String left, String right) {
        int[] costs = new int[right.length() + 1];
        for (int j = 0; j <= right.length(); j++) {
            costs[j] = j;
        }
        for (int i = 1; i <= left.length(); i++) {
            costs[0] = i;
            int previous = i - 1;
            for (int j = 1; j <= right.length(); j++) {
                int current = costs[j];
                costs[j] = left.charAt(i - 1) == right.charAt(j - 1)
                        ? previous
                        : 1 + Math.min(previous, Math.min(costs[j], costs[j - 1]));
                previous = current;
            }
        }
        return costs[right.length()];
    }

    private ChatLanguage detectLanguage(String text) {
        return text.chars().anyMatch(ch -> Character.UnicodeBlock.of(ch) == Character.UnicodeBlock.CYRILLIC)
                ? ChatLanguage.RU
                : ChatLanguage.EN;
    }

    private String normalize(String text) {
        return Normalizer.normalize(text.toLowerCase(Locale.ROOT), Normalizer.Form.NFKD)
                .replaceAll("[^\\p{IsAlphabetic}\\p{IsDigit}\\s]", " ")
                .replaceAll("\\s+", " ")
                .strip();
    }
}