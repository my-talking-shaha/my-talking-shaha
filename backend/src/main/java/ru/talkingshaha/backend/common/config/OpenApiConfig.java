package ru.talkingshaha.backend.common.config;

import io.swagger.v3.oas.annotations.OpenAPIDefinition;
import io.swagger.v3.oas.annotations.info.Info;
import org.springframework.context.annotation.Configuration;

@Configuration
@OpenAPIDefinition(
        info = @Info(
                title = "My Talking Shaha API",
                version = "0.1.0",
                description = "Garage, vehicle dashboard, and vehicle parts API"))
public class OpenApiConfig {
}
