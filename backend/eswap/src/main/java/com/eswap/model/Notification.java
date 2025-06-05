package com.eswap.model;

import com.eswap.common.constants.NotificationCategory;
import com.eswap.common.constants.NotificationType;
import com.eswap.common.constants.RecipientType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.io.Serializable;
import java.time.OffsetDateTime;

@Entity
@Table(name = "notifications")
@Getter
@Setter
public class Notification implements Serializable {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private Long senderId;
    private String senderRole;
    @Enumerated(EnumType.STRING)
    private RecipientType recipientType;
    private Long recipientId;
    @Enumerated(EnumType.STRING)
    private NotificationCategory category;
    @Enumerated(EnumType.STRING)
    private NotificationType type;
    private String title;
    private String message;
    private Long postId;
    private boolean isRead = false;
    private String orderId;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;
}
