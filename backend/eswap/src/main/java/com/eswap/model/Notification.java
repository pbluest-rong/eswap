package com.eswap.model;

import com.eswap.common.constants.NotificationCategory;
import com.eswap.common.constants.NotificationType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import java.io.Serializable;
import java.time.LocalDateTime;

@Entity
@Table(name = "notifications")
@Getter
@Setter
public class Notification implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;

    private Long userId;  // Người nhận thông báo

    private String message;  // Nội dung thông báo

    @Enumerated(EnumType.STRING)
    private NotificationType type; // Loại thông báo (IMPORTANT, TEMPORARY)

    @Enumerated(EnumType.STRING)
    private NotificationCategory category; // Danh mục thông báo (ORDER, MESSAGE, SYSTEM, PROMOTION)

    private boolean isRead = false; // Đã đọc chưa?

    private LocalDateTime createdAt = LocalDateTime.now(); // Thời gian tạo
}
