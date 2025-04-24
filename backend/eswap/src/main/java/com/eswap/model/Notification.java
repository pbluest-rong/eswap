package com.eswap.model;

import com.eswap.common.constants.NotificationCategory;
import com.eswap.common.constants.NotificationType;
import com.eswap.common.constants.RecipientType;
import com.fasterxml.jackson.annotation.JsonFormat;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.io.Serializable;
import java.sql.Timestamp;
import java.util.Map;

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

    @CreationTimestamp
    @JsonFormat(shape = JsonFormat.Shape.STRING, pattern = "yyyy-MM-dd HH:mm:ss")
    private Timestamp createdAt;
}
