package com.eswap.kafka.post;

import com.eswap.response.PostResponse;
import jakarta.transaction.Transactional;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class PostProducer {
    private final KafkaTemplate<String, Object> kafkaTemplate;

    public PostProducer(KafkaTemplate<String, Object> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    @Transactional
    public void sendPostCreatedEvent(PostResponse post) {
        kafkaTemplate.executeInTransaction(operations -> {
            operations.send(PostKafkaConfig.NEW_TOPIC,
                    String.valueOf(post.getId()),
                    post
            );
            System.out.println("Sent post to Kafka: " + post);
            return null;
        });
    }
}