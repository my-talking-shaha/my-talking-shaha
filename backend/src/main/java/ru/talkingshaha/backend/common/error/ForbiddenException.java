package ru.talkingshaha.backend.common.error;

/**
 * Thrown when the current user tries to access a resource that belongs to another user.
 * Mapped to HTTP 403 with error code {@code FORBIDDEN}.
 */
public class ForbiddenException extends RuntimeException {
    public ForbiddenException(String message) {
        super(message);
    }
}
