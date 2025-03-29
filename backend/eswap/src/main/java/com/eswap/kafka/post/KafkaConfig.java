package com.eswap.kafka.post;

import com.eswap.response.PostResponse;
import jakarta.persistence.EntityManagerFactory;
import org.apache.kafka.clients.admin.NewTopic;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.kafka.config.ConcurrentKafkaListenerContainerFactory;
import org.springframework.kafka.config.TopicBuilder;
import org.springframework.kafka.core.*;
import org.springframework.kafka.support.serializer.JsonDeserializer;
import org.springframework.kafka.support.serializer.JsonSerializer;
import org.springframework.kafka.transaction.KafkaTransactionManager;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.transaction.PlatformTransactionManager;
import org.springframework.transaction.annotation.EnableTransactionManagement;

import java.util.HashMap;
import java.util.Map;

@Configuration
@EnableTransactionManagement
public class KafkaConfig {

    @Value("${spring.kafka.bootstrap-servers}")
    private String bootstrapServers;

    private Map<String, Object> producerConfigs(Class<?> valueSerializer) {
        Map<String, Object> configProps = new HashMap<>();
        configProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        configProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class);
        configProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, valueSerializer);

        // Cấu hình Transaction
        configProps.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "new-post-tx");
        configProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        configProps.put(ProducerConfig.ACKS_CONFIG, "all");
        configProps.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);

        return configProps;
    }

    @Bean
    public ProducerFactory<String, PostResponse> postProducerFactory() {
        DefaultKafkaProducerFactory<String, PostResponse> factory = new DefaultKafkaProducerFactory<>(producerConfigs(JsonSerializer.class));
        factory.setTransactionIdPrefix("new-post-tx");
        return factory;
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
        return new JpaTransactionManager(entityManagerFactory);
    }
    @Bean
    public NewTopic eswapTopic() {
        return TopicBuilder.name("new-post")
                .partitions(3)
                .replicas(2)
                .build();
    }

    @Bean
    public ConsumerFactory<String, PostResponse> postConsumerFactory() {
        Map<String, Object> props = new HashMap<>();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "post-group");
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class);
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, JsonDeserializer.class);
        props.put(JsonDeserializer.TRUSTED_PACKAGES, "*");

        return new DefaultKafkaConsumerFactory<>(props, new StringDeserializer(), new JsonDeserializer<>(PostResponse.class));
    }

    @Bean
    public ConcurrentKafkaListenerContainerFactory<String, PostResponse> postKafkaListenerContainerFactory() {
        ConcurrentKafkaListenerContainerFactory<String, PostResponse> factory = new ConcurrentKafkaListenerContainerFactory<>();
        factory.setConsumerFactory(postConsumerFactory());
        return factory;
    }
}
