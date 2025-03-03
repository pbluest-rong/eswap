package com.ecoswap.common.exception;

public class FileExistsException extends RuntimeException {
    public FileExistsException(String message) {
        super(message);
    }
}
