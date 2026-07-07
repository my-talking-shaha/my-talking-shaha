package ru.talkingshaha.backend.vehicle.service;

import java.util.UUID;

import org.springframework.web.servlet.support.ServletUriComponentsBuilder;

public final class PhotoUrls {

    private PhotoUrls() {
    }

    public static String publicUrl(UUID photoId) {
        return ServletUriComponentsBuilder.fromCurrentContextPath()
                .path("/api/v1/photos/{photoId}")
                .buildAndExpand(photoId)
                .toUriString();
    }
}
