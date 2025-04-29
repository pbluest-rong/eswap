package com.eswap.response;

import com.eswap.common.constants.ContentType;
import com.eswap.model.Message;
import lombok.*;

import java.sql.Timestamp;
import java.time.OffsetDateTime;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class MessageResponse {
    private long id;
    private OffsetDateTime createdAt;
    private long fromUserId;
    private long toUserId;
    private ContentType contentType;
    private String content;
    private boolean isRead;


    private String fromUserUsername;
    private String fromUserFirstName;
    private String fromUserLastName;
    private String toUserUsername;

    public static MessageResponse mapperToResponse(Message message) {
        return MessageResponse.builder()
                .id(message.getId())
                .createdAt(message.getCreatedAt())
                .fromUserId(message.getFromUser().getId())
                .toUserId(message.getToUser().getId())
                .contentType(message.getContentType())
                .content(message.getContent())
                .fromUserUsername(message.getFromUser().getUsername())
                .fromUserFirstName(message.getFromUser().getFirstName())
                .fromUserLastName(message.getFromUser().getLastName())
                .toUserUsername(message.getToUser().getUsername())
                .isRead(message.isRead())
                .build();
    }
}