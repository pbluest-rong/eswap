package com.eswap.kafka.post;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class PostKafkaConfig {
    public static final String NEW_TOPIC = "new-post";

    @Bean
    public NewTopic newPostTopic() {
        return TopicBuilder.name(NEW_TOPIC)
                .partitions(3)
                .replicas(2)
                .build();
    }
}