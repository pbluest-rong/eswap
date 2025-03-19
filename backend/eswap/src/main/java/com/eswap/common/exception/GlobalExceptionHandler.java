package com.eswap.common.exception;

import com.eswap.common.ErrorResponse;
import com.eswap.common.constants.AppErrorCode;
import jakarta.validation.ConstraintViolationException;
import lombok.RequiredArgsConstructor;
import org.springframework.context.MessageSource;
import org.springframework.context.i18n.LocaleContextHolder;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.bind.MethodArgumentNotValidException;

import java.util.*;
import java.util.stream.Collectors;

@RestControllerAdvice
@RequiredArgsConstructor
public class GlobalExceptionHandler {
    private final MessageSource messageSource;

    @ExceptionHandler(ResourceNotFoundException.class)
    public ResponseEntity<ErrorResponse> handleResourceNotFoundException(ResourceNotFoundException ex) {
        Locale locale = LocaleContextHolder.getLocale();
        String message = messageSource.getMessage(ex.getMessage(), ex.getArgs(), locale);

        return ResponseEntity.status(HttpStatus.NOT_FOUND)
                .body(new ErrorResponse(false, HttpStatus.NOT_FOUND.value(), HttpStatus.NOT_FOUND.getReasonPhrase(), ex.getErrorCode().getCode(), message));
    }

    @ExceptionHandler(AlreadyExistsException.class)
    public ResponseEntity<ErrorResponse> handleAlreadyExistsException(AlreadyExistsException ex) {
        Locale locale = LocaleContextHolder.getLocale();
        String message = messageSource.getMessage(ex.getErrorCode().getMessageKey(), ex.getArgs(), locale);
        return ResponseEntity.status(HttpStatus.CONFLICT)
                .body(new ErrorResponse(false, HttpStatus.CONFLICT.value(), HttpStatus.CONFLICT.getReasonPhrase(), ex.getErrorCode().getCode(), message));
    }

    @ExceptionHandler(InvalidCredentialsException.class)
    public ResponseEntity<ErrorResponse> handleAlreadyExistsException(InvalidCredentialsException ex) {
        Locale locale = LocaleContextHolder.getLocale();
        String message = messageSource.getMessage(ex.getErrorCode().getMessageKey(), ex.getArgs(), locale);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(false, HttpStatus.BAD_REQUEST.value(), HttpStatus.BAD_REQUEST.getReasonPhrase(), ex.getErrorCode().getCode(), message));
    }


    @ExceptionHandler(AccountLockedException.class)
    public ResponseEntity<ErrorResponse> handleAccountLockedException(AccountLockedException ex) {
        Locale locale = LocaleContextHolder.getLocale();
        String message = messageSource.getMessage(ex.getErrorCode().getMessageKey(), ex.getArgs(), locale);
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(new ErrorResponse(false, HttpStatus.FORBIDDEN.value(), HttpStatus.FORBIDDEN.getReasonPhrase(), ex.getErrorCode().getCode(), message));

    }

    @ExceptionHandler(OperationNotPermittedException.class)
    public ResponseEntity<ErrorResponse> handleOperationNotPermittedException(OperationNotPermittedException ex) {
        Locale locale = LocaleContextHolder.getLocale();
        String message = messageSource.getMessage(ex.getErrorCode().getMessageKey(), ex.getArgs(), locale);
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(new ErrorResponse(false, HttpStatus.FORBIDDEN.value(), HttpStatus.FORBIDDEN.getReasonPhrase(), ex.getErrorCode().getCode(), message));

    }

    @ExceptionHandler(UserNotEnabledException.class)
    public ResponseEntity<ErrorResponse> handleUserNotEnabledException(UserNotEnabledException ex) {
        Locale locale = LocaleContextHolder.getLocale();
        String message = messageSource.getMessage(ex.getErrorCode().getMessageKey(), ex.getArgs(), locale);
        return ResponseEntity.status(HttpStatus.FORBIDDEN)
                .body(new ErrorResponse(false, HttpStatus.FORBIDDEN.value(), HttpStatus.FORBIDDEN.getReasonPhrase(), ex.getErrorCode().getCode(), message));
    }

    @ExceptionHandler(CodeInvalidException.class)
    public ResponseEntity<ErrorResponse> handleCodeInvalidException(CodeInvalidException ex) {
        Locale locale = LocaleContextHolder.getLocale();
        String message = messageSource.getMessage(ex.getErrorCode().getMessageKey(), ex.getArgs(), locale);
        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(false, HttpStatus.BAD_REQUEST.value(), HttpStatus.BAD_REQUEST.getReasonPhrase(), ex.getErrorCode().getCode(), message));
    }

    @ExceptionHandler(OtpLimitExceededException.class)
    public ResponseEntity<ErrorResponse> handleOtpLimitExceededException(OtpLimitExceededException ex) {
        Locale locale = LocaleContextHolder.getLocale();
        String message = messageSource.getMessage(ex.getErrorCode().getMessageKey(), ex.getArgs(), locale);
        return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS)
                .body(new ErrorResponse(false, HttpStatus.TOO_MANY_REQUESTS.value(), HttpStatus.TOO_MANY_REQUESTS.getReasonPhrase(),
                        ex.getErrorCode().getCode(), message));
    }

    @ExceptionHandler({MethodArgumentNotValidException.class, ConstraintViolationException.class})
    public ResponseEntity<ErrorResponse> handleValidationException(Exception ex) {
        Locale locale = LocaleContextHolder.getLocale();
        List<Map<String, String>> errors = new ArrayList<>();

        if (ex instanceof MethodArgumentNotValidException manve) {
            errors = manve.getBindingResult().getFieldErrors().stream()
                    .map(error -> Map.of(
                            "field", error.getField(),
                            "error", messageSource.getMessage(error, locale)
                    ))
                    .collect(Collectors.toList());
        } else if (ex instanceof ConstraintViolationException cve) {
            errors = cve.getConstraintViolations().stream()
                    .map(violation -> Map.of(
                            "field", violation.getPropertyPath().toString(),
                            "error", violation.getMessage()
                    ))
                    .collect(Collectors.toList());
        }

        String message = messageSource.getMessage(AppErrorCode.VALIDATION_FAILED.getMessageKey(), errors.toArray(), locale);

        return ResponseEntity.status(HttpStatus.BAD_REQUEST)
                .body(new ErrorResponse(false, HttpStatus.BAD_REQUEST.value(), HttpStatus.BAD_REQUEST.getReasonPhrase(), AppErrorCode.VALIDATION_FAILED.getCode(), message));
    }
}
