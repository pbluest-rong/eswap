package com.eswap.kafka.post;

import com.eswap.common.constants.NotificationCategory;
import com.eswap.common.constants.NotificationType;
import com.eswap.common.constants.RecipientType;
import com.eswap.model.User;
import com.eswap.response.PostResponse;
import com.eswap.service.UserService;
import com.eswap.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.kafka.annotation.KafkaListener;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
@RequiredArgsConstructor
public class PostConsumer {
    private final NotificationService notificationService;
    private final SimpMessagingTemplate messagingTemplate;
    private final UserService userService;

    @KafkaListener(topics = PostKafkaConfig.NEW_TOPIC, groupId = "post-group-notification")
    public void processNewPostFcm(PostResponse post) {
        notificationService.createAndPushNotification(
                post.getUserId(),
                RecipientType.FOLLOWERS,
                NotificationCategory.NEW_POST_FOLLOWER,
                NotificationType.INFORM,
                "Người dùng following đăng bài mới",
                post.getFirstname() + " " + post.getLastname() + " đã đăng bài viết mới",
                post.getId(),
                null,
                null
        );
    }

    @KafkaListener(topics = PostKafkaConfig.NEW_TOPIC, groupId = "post-group-websocket")
    public void processNewPostWebSocket(PostResponse post) {
        try {
            System.out.println("Kafka: new-post post-group-websocket " + post);
            List<User> followers = userService.getFollowers(post.getUserId());

            followers.forEach(f -> {
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
}