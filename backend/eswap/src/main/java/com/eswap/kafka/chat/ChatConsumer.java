package com.eswap.kafka.chat;

import com.eswap.common.constants.NotificationCategory;
import com.eswap.common.constants.NotificationType;
import com.eswap.common.constants.RecipientType;
import com.eswap.kafka.post.PostKafkaConfig;
import com.eswap.model.User;
import com.eswap.response.MessageResponse;
import com.eswap.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class ChatConsumer {
    private final NotificationService notificationService;
    private final SimpMessagingTemplate messagingTemplate;

    @KafkaListener(topics = ChatKafkaConfig.NEW_MESSAGE_TOPIC, groupId = "chat-group-notification")
    public void processNewMessageFcm(MessageResponse message) {
        System.out.println("Kafka: new-message message-group-notification " + message);
        notificationService.createAndPushNotification(
                message.getFromUserId(),
                RecipientType.INDIVIDUAL,
                NotificationCategory.NEW_MESSAGE,
                NotificationType.INFORM,
                "Bạn có tin nhắn mới từ " + message.getFromUserFirstName() + " " + message.getFromUserLastName(),
                message.getContent(),
                null,
                message.getToUserId()
        );
    }

    @KafkaListener(topics = ChatKafkaConfig.NEW_MESSAGE_TOPIC, groupId = "chat-group-websocket")
    public void processNewMessageWebSocket(MessageResponse message) {
        System.out.println("Kafka: new-message message-group-websocket " + message);
        try {
            System.out.println("Kafka: new-message message-group-websocket " + message);
            messagingTemplate.convertAndSendToUser(
                    message.getFromUserUsername(),
                    "/queue/new-message",
                    message
            );
            messagingTemplate.convertAndSendToUser(
                    message.getToUserUsername(),
                    "/queue/new-message",
                    message
            );
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
