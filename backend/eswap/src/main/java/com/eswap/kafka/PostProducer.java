package com.eswap.kafka;

import com.eswap.response.PostResponse;
import jakarta.transaction.Transactional;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.stereotype.Service;

@Service
public class PostProducer {
    private final KafkaTemplate<String, PostResponse> postKafkaTemplate;

    public PostProducer(KafkaTemplate<String, PostResponse> postKafkaTemplate) {
        this.postKafkaTemplate = postKafkaTemplate;
    }

    @Transactional
    public void sendPostCreatedEvent(PostResponse post) {
        postKafkaTemplate.executeInTransaction(operations -> {
            operations.send(KafkaConfig.NEW_TOPIC, String.valueOf(post.getId()), post);
            System.out.println("Sent post to Kafka: " + post);
            return null;
        });
    }
}
