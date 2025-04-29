package com.eswap.kafka.chat;

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
    public void sendPostCreatedEvent(MessageResponse message) {
        kafkaTemplate.executeInTransaction(operations -> {
            operations.send(ChatKafkaConfig.NEW_MESSAGE_TOPIC,
                    String.valueOf(message.getId()),
                    message
            );
            System.out.println("Sent message to Kafka: " + message);
            return null;
        });
    }
}