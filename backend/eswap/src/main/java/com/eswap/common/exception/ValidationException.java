package com.eswap.common.exception;

import com.eswap.common.constants.AppErrorCode;

public class ValidationException extends RuntimeException {
    private final AppErrorCode errorCode;
    private final Object[] args;

    public ValidationException(AppErrorCode errorCode, Object... args) {
        super(errorCode.getMessageKey());
        this.errorCode = errorCode;
        this.args = args;
    }

    public AppErrorCode getErrorCode() {
        return errorCode;
    }

    public Object[] getArgs() {
        return args;
    }
}
