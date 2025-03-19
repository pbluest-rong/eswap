package com.eswap.kafka.service;

import com.eswap.kafka.payload.User;
import org.springframework.kafka.core.KafkaTemplate;
import org.springframework.kafka.support.KafkaHeaders;
import org.springframework.messaging.support.MessageBuilder;
import org.springframework.messaging.Message;

import org.springframework.stereotype.Service;

import java.util.logging.Logger;

@Service
public class JsonKafkaProducer {
    private static final Logger LOGGER = Logger.getLogger(JsonKafkaProducer.class.getName());

    private KafkaTemplate<String, User> kafkaTemplate;

    public JsonKafkaProducer(KafkaTemplate<String, User> kafkaTemplate) {
        this.kafkaTemplate = kafkaTemplate;
    }

    public void sendMessage(User user) {
        LOGGER.info(String.format("Message sent to Kafka: %s", user));
        Message<User> message = MessageBuilder.withPayload(user)
                .setHeader(KafkaHeaders.TOPIC, "pblues_json").build();
        kafkaTemplate.send(message);
    }
}
