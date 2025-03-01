package com.studentswap.common.enums;

import java.time.LocalDateTime;
import java.time.temporal.ChronoUnit;

public enum AvailableTime {
    ONE_WEEK(ChronoUnit.WEEKS, 1),
    ONE_MONTH(ChronoUnit.MONTHS, 1),
    THREE_MONTHS(ChronoUnit.MONTHS, 3),
    ONE_YEAR(ChronoUnit.YEARS, 1);

    private final ChronoUnit unit;
    private final long amount;

    AvailableTime(ChronoUnit unit, long amount) {
        this.unit = unit;
        this.amount = amount;
    }

    public LocalDateTime calculateExpirationTime(LocalDateTime createdAt) {
        return createdAt.plus(amount, unit);
    }
}
