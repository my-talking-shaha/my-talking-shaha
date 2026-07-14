package ru.talkingshaha.backend.common.storage;

import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;

public record PhotoContent(MediaType contentType, Resource resource) {
}
