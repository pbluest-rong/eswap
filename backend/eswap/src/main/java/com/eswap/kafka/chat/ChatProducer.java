package com.eswap.kafka.chat;

import com.eswap.response.ChatResponse;
import com.eswap.response.MessageResponse;
import jakarta.transaction.Transactional;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class ChatProducer {
    private final KafkaTemplate<String, Object> kafkaTemplate;

    public ChatProducer(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    @Transactional
    public void sendPostCreatedEvent(ChatResponse chat) {
        kafkaTemplate.executeInTransaction(operations -> {
            operations.send(ChatKafkaConfig.NEW_MESSAGE_TOPIC,
                    String.valueOf(chat.getId()),
                    chat
            );
            System.out.println("Sent message to Kafka: " + chat);
            return null;
        });
    }
}