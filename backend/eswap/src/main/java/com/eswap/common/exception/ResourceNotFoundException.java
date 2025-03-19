package com.eswap.common.exception;

import com.eswap.common.constants.AppErrorCode;

public class ResourceNotFoundException extends RuntimeException {
    private final AppErrorCode errorCode;
    private final Object[] args;

    public ResourceNotFoundException(AppErrorCode errorCode, Object... args) {
        super(errorCode.getMessageKey()); // Key từ AppErrorCode
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
