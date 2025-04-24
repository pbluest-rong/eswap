package com.eswap.kafka;

import com.eswap.response.PostResponse;
import jakarta.persistence.EntityManagerFactory;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.springframework.boot.autoconfigure.kafka.KafkaProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.transaction.ChainedTransactionManager;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.*;
import org.springframework.kafka.support.serializer.JsonDeserializer;
import org.springframework.kafka.transaction.KafkaTransactionManager;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import java.util.Map;

@Configuration
@EnableTransactionManagement
public class KafkaConfig {

    public static final String NEW_TOPIC = "new-post";

    private final KafkaProperties kafkaProperties;

    public KafkaConfig(KafkaProperties kafkaProperties) {
        this.kafkaProperties = kafkaProperties;
    }

    // ------------------- PRODUCER -------------------

    @Bean
    public ProducerFactory<String, PostResponse> postProducerFactory() {
        Map<String, Object> configProps = kafkaProperties.buildProducerProperties();
        configProps.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "post-producer-tx-");
        configProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        configProps.put(ProducerConfig.ACKS_CONFIG, "all");
        return new DefaultKafkaProducerFactory<>(configProps);
    }

    @Bean
    public KafkaTemplate<String, PostResponse> postKafkaTemplate() {
        return new KafkaTemplate<>(postProducerFactory());
    }

    @Bean
    public KafkaTransactionManager<String, PostResponse> kafkaTransactionManager() {
        return new KafkaTransactionManager<>(postProducerFactory());
    }

    @Bean
    @Primary
    public PlatformTransactionManager transactionManager(EntityManagerFactory entityManagerFactory) {
        // Kết hợp Kafka và JPA transaction managers
        return new ChainedTransactionManager(kafkaTransactionManager(), new JpaTransactionManager(entityManagerFactory));
    }
    // ------------------- TRANSACTION MANAGER -------------------

    @Bean
    public PlatformTransactionManager jpaTransactionManager(EntityManagerFactory entityManagerFactory) {
        return new JpaTransactionManager(entityManagerFactory);
    }

    @Bean
    public PlatformTransactionManager chainedTransactionManager(
            EntityManagerFactory entityManagerFactory,
            KafkaTransactionManager<String, PostResponse> kafkaTxManager) {
        return new ChainedTransactionManager(kafkaTxManager, jpaTransactionManager(entityManagerFactory));
    }

    // ------------------- TOPICS -------------------

    @Bean
    public NewTopic newPostTopic() {
        return TopicBuilder.name(NEW_TOPIC)
                .partitions(3)
                .replicas(2)
                .build();
    }
    // ------------------- CONSUMER: PostResponse -------------------

    @Bean
    public ConsumerFactory<String, PostResponse> newPostConsumerFactory() {
        Map<String, Object> props = kafkaProperties.buildConsumerProperties();
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "new-post-group");

        JsonDeserializer<PostResponse> deserializer = new JsonDeserializer<>(PostResponse.class);
        deserializer.addTrustedPackages("*");

        return new DefaultKafkaConsumerFactory<>(props, new StringDeserializer(), deserializer);
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, PostResponse> newPostKafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, PostResponse> factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(newPostConsumerFactory());
        return factory;
    }
}
