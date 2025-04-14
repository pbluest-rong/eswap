package com.eswap.kafka.post;

import com.eswap.common.constants.NotificationCategory;
import com.eswap.common.constants.NotificationType;
import com.eswap.common.constants.RecipientType;
import com.eswap.model.Post;
import com.eswap.model.User;
import com.eswap.response.PostResponse;
import com.eswap.service.UserService;
import com.eswap.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.messaging.simp.annotation.SendToUser;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PostConsumer {
    private final NotificationService notificationService;
    private final SimpMessagingTemplate messagingTemplate;
    private final UserService userService;

    @KafkaListener(topics = "new-post", groupId = "post-group-notification", containerFactory = "postKafkaListenerContainerFactory")
    public void processNewPost(PostResponse post) {
        System.out.println("Kafka: new-post post-group-notification " + post);
        notificationService.createAndPushNotification(
                post.getUserId(),
                RecipientType.FOLLOWERS,
                NotificationCategory.NEW_POST_FOLLOWER,
                NotificationType.IMPORTANT,
                "Người dùng following đăng bài mới",
                post.getUserId()+"",
                null
        );
    }
    @KafkaListener(topics = "new-post", groupId = "post-group-websocket")
    public void processNewPostWebSocket(PostResponse post) {
        try {
            System.out.println("Kafka: new-post post-group-websocket " + post);
            List<User> followers = userService.getFollowers(post.getUserId());
            System.out.println("Sending to " + followers.size() + " followers");

            followers.forEach(f -> {
                System.out.println("Sending to user: " + f.getId());
                messagingTemplate.convertAndSendToUser(
                        f.getUsername(),
                        "/queue/new-posts",
                        post
                );
            });
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
//    @KafkaListener(topics = "new-post", groupId = "post-group-websocket-test")
//    public void testWebSocket(PostResponse post) {
//        messagingTemplate.convertAndSend("/topic/new-post", post);
//    }
}
