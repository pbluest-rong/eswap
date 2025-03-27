package com.eswap.kafka.post;

import com.eswap.model.Post;
import com.eswap.response.PostResponse;
import jakarta.transaction.Transactional;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class PostProducer {
    private final KafkaTemplate<String, PostResponse> kafkaTemplate;
    private static final String TOPIC = "new-post";

    public PostProducer(KafkaTemplate<String, PostResponse> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    @Transactional
    public void sendPostCreatedEvent(PostResponse post) {
        kafkaTemplate.executeInTransaction(operations -> {
            operations.send(TOPIC, String.valueOf(post.getId()), post);
            System.out.println("✅ Sent post to Kafka: " + post);
            return null;
        });
    }
}
