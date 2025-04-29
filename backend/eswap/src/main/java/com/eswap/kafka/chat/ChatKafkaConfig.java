package com.eswap.kafka.chat;

import org.apache.kafka.clients.admin.NewTopic;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.kafka.config.TopicBuilder;

@Configuration
public class ChatKafkaConfig {
    public static final String NEW_MESSAGE_TOPIC = "new-message";

    @Bean
    public NewTopic newChatTopic() {
        return TopicBuilder.name(NEW_MESSAGE_TOPIC)
                .partitions(3)
                .replicas(2)
                .build();
    }
}