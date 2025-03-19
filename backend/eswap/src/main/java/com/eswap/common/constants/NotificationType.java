package com.eswap.common.constants;

public enum NotificationType {
    IMPORTANT,  // Lưu vào Database + Redis
    TEMPORARY   // Chỉ lưu vào Redis (TTL = 30 ngày)
}
