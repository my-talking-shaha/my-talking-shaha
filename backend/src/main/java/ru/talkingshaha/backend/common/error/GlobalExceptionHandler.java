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
import org.springframework.web.method.annotation.MethodArgumentTypeMismatchException;

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

    @ExceptionHandler(MethodArgumentTypeMismatchException.class)
    public ResponseEntity<ApiError> handleTypeMismatch(MethodArgumentTypeMismatchException exception) {
        log.warn("API error code=VALIDATION_ERROR parameter={}", exception.getName());
        return ResponseEntity.badRequest()
                .body(new ApiError(
                        "VALIDATION_ERROR",
                        "Request contains invalid fields",
                        Map.of(exception.getName(), "Invalid value")));
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

    @ExceptionHandler(EmailAlreadyExistsException.class)
    public ResponseEntity<ApiError> handleEmailExists(EmailAlreadyExistsException exception) {
        log.warn("API error code=EMAIL_ALREADY_EXISTS message={}", exception.getMessage());
        return ResponseEntity.status(HttpStatus.CONFLICT).body(ApiError.of("EMAIL_ALREADY_EXISTS", exception.getMessage()));
    }

    @ExceptionHandler(InvalidCredentialsException.class)
    public ResponseEntity<ApiError> handleInvalidCredentials(InvalidCredentialsException exception) {
        log.warn("API error code=INVALID_CREDENTIALS");
        return ResponseEntity.status(HttpStatus.UNAUTHORIZED).body(ApiError.of("INVALID_CREDENTIALS", exception.getMessage()));
    }

    private String fieldMessage(FieldError fieldError) {
        return fieldError.getDefaultMessage() == null ? "Invalid value" : fieldError.getDefaultMessage();
    }
}
