package com.eswap.response;

import com.eswap.model.Notification;
import lombok.*;

import java.sql.Timestamp;
import java.time.OffsetDateTime;
import java.util.Map;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class NotificationResponse {
    private Long id;
    private Long senderId;
    private String senderFirstName;
    private String senderLastName;
    private String senderRole;
    private String category;
    private String type;
    private boolean read;
    private Long postId;
    private OffsetDateTime createdAt;
    private String avatarUrl;
}
