package com.eswap.response;

import com.eswap.model.Notification;
import lombok.*;

import java.sql.Timestamp;
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
    private Timestamp createdAt;
    private String avatarUrl;
}
