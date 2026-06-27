package ru.talkingshaha.backend.chat.config;

import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.web.client.RestClient;

@Configuration
public class AiChatRestClientConfig {

    @Bean
    public RestClient huggingFaceRestClient(AiChatProperties properties) {
        return RestClient.builder().baseUrl(properties.baseUrl()).build();
    }
}