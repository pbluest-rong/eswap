package com.ecoswap.common.exception;

public class UserNotEnabledException extends RuntimeException {
    public UserNotEnabledException(String message) {
        super(message);
    }
}