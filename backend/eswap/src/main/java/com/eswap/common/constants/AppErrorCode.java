package com.eswap.common.constants;

public enum AppErrorCode {
    USER_NOT_FOUND("USER_NOT_FOUND", "error.user.not_found"),
    POST_NOT_FOUND("POST_NOT_FOUND", "error.post.not_found"),
    EDUCATION_INSTITUTION_NOT_FOUND("POST_NOT_FOUND", "error.education_institution.not_found"),
    MEDIA_NOT_FOUND("MEDIA_NOT_FOUND", "error.media.not_found"),
    USER_EXISTS("USER_EXISTS", "error.user.exists"),
    USER_INVALID_CREDENTIALS("USER_INVALID_CREDENTIALS", "error.auth.invalid_credentials"),
    USER_PW_INVALID_CREDENTIALS("USER_PW_INVALID_CREDENTIALS", "error.auth.pw_invalid_credentials"),
    USER_LOCKED("USER_LOCKED", "error.user.locked"),
    AUTH_INVALID_CODE("AUTH_INVALID_CODE", "error.auth.invalid_code"),
    AUTH_FORBIDDEN("AUTH_FORBIDDEN", "error.auth.forbidden"),
    VALIDATION_FAILED("VALIDATION_FAILED", "error.auth.validation_failed"),
    PROVINCE_NOT_FOUND("PROVINCE_NOT_FOUND", "error.province.not_found"),
    OTP_LIMIT_EXCEEDED("OTP_LIMIT_EXCEEDED", "error.otp.limit_exceeded"),
    AUTH_TOKEN_MISSING("AUTH_TOKEN_MISSING", "error.auth.token_missing"),
    AUTH_TOKEN_EXPRIED("AUTH_TOKEN_EXPRIED", "error.auth.token_expired"),
    FOLLOW_USER_FOLLOWED("FOLLOW_USER_FOLLOWED", "error.follow.user_followed"),
    LIKE_POST_EXISTS("LIKE_POST_EXISTS", "error.post.like_exists"),
    LIKE_NOT_FOUND("LIKE_NOT_FOUND", "error.post.like_not_found"),
    CHAT_NOT_FOUND("CHAT_NOT_FOUND", "error.chat.not_found"),
    ORDER_NOT_FOUND("ORDER_NOT_FOUND", "error.order.not_found"),
    ORDER_EXISTS("ORDER_EXISTS", "error.order.exists"),
    DEPOSIT_LIMIT_EXCEEDED("DEPOSIT_LIMIT_EXCEEDED", "error.order.limit_exceeded"),
    WITHDRAWAL_REQUEST_LIMIT_EXCEEDED("WITHDRAWAL_LIMIT_EXCEEDED", "error.balance.request_limit_exceeded");
    private final String code;
    private final String messageKey;

    AppErrorCode(String code, String messageKey) {
        this.code = code;
        this.messageKey = messageKey;
    }

    public String getCode() {
        return code;
    }

    public String getMessageKey() {
        return messageKey;
    }
}
