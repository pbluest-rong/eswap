package com.eswap.kafka.chat;

import com.eswap.common.constants.NotificationCategory;
import com.eswap.common.constants.NotificationType;
import com.eswap.common.constants.RecipientType;
import com.eswap.kafka.post.PostKafkaConfig;
import com.eswap.model.User;
import com.eswap.response.ChatResponse;
import com.eswap.response.MessageResponse;
import com.eswap.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;


@Service
@RequiredArgsConstructor
public class ChatConsumer {
    private final NotificationService notificationService;
    private final SimpMessagingTemplate messagingTemplate;

    @KafkaListener(topics = ChatKafkaConfig.NEW_MESSAGE_TOPIC, groupId = "chat-group-notification")
    public void processNewMessageFcm(ChatResponse chat) {
        System.out.println("Kafka: new-message message-group-notification " + chat);
        if (!chat.isForMe())
            notificationService.createAndPushNotification(
                    chat.getChatPartnerId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.NEW_MESSAGE,
                    NotificationType.INFORM,
                    "Bạn có tin nhắn mới từ " + chat.getMostRecentMessage().getFromUserFirstName() + " " + chat.getMostRecentMessage().getFromUserLastName(),
                    chat.getMostRecentMessage().getContent(),
                    null,
                    chat.getMostRecentMessage().getToUserId()
            );
    }

    @KafkaListener(topics = ChatKafkaConfig.NEW_MESSAGE_TOPIC, groupId = "chat-group-websocket")
    public void processNewMessageWebSocket(ChatResponse chat) {
        System.out.println("Kafka: new-message message-group-websocket " + chat);
        try {
            if (chat.isForMe()) {
                System.out.println("Me => " + chat);
                messagingTemplate.convertAndSendToUser(
                        chat.getMostRecentMessage().getFromUserUsername(),
                        "/queue/new-message",
                        chat
                );
            }
            if (!chat.isForMe()) {
                System.out.println("Not Me => " + chat);
                messagingTemplate.convertAndSendToUser(
                        chat.getMostRecentMessage().getToUserUsername(),
                        "/queue/new-message",
                        chat
                );
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
