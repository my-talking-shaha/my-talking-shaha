package ru.talkingshaha.backend.common.error;

import java.util.Map;
import java.util.stream.Collectors;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

/**
 * Translates application exceptions into the common {@link ApiError} response.
 *
 * <p>Mapping: bean-validation failures and {@link IllegalArgumentException} → 400
 * {@code VALIDATION_ERROR}; {@link ResourceNotFoundException} → 404 {@code NOT_FOUND};
 * {@link ForbiddenException} → 403 {@code FORBIDDEN}.
 */
@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiError> handleValidation(MethodArgumentNotValidException exception) {
        Map<String, String> fields =
                exception.getBindingResult().getFieldErrors().stream()
                        .collect(Collectors.toMap(FieldError::getField, this::fieldMessage, (left, right) -> left));
        log.warn("API error code=VALIDATION_ERROR fields={}", fields.keySet());
        return ResponseEntity.badRequest()
                .body(new ApiError("VALIDATION_ERROR", "Request contains invalid fields", fields));
    }

    @ExceptionHandler(IllegalArgumentException.class)
    public ResponseEntity<ApiError> handleIllegalArgument(IllegalArgumentException exception) {
        log.warn("API error code=VALIDATION_ERROR message={}", exception.getMessage());
        return ResponseEntity.badRequest().body(ApiError.of("VALIDATION_ERROR", exception.getMessage()));
    }

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ApiError> handleNotFound(ResourceNotFoundException exception) {
        log.warn("API error code=NOT_FOUND message={}", exception.getMessage());
        return ResponseEntity.status(HttpStatus.NOT_FOUND).body(ApiError.of("NOT_FOUND", exception.getMessage()));
    }

    @ExceptionHandler(ForbiddenException.class)
    public ResponseEntity<ApiError> handleForbidden(ForbiddenException exception) {
        log.warn("API error code=FORBIDDEN message={}", exception.getMessage());
        return ResponseEntity.status(HttpStatus.FORBIDDEN).body(ApiError.of("FORBIDDEN", exception.getMessage()));
    }

    private String fieldMessage(FieldError fieldError) {
        return fieldError.getDefaultMessage() == null ? "Invalid value" : fieldError.getDefaultMessage();
    }
}