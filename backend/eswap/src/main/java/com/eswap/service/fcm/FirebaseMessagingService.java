package com.eswap.service.fcm;

import com.eswap.model.UserFcmToken;
import com.eswap.repository.FcmTokenRepository;
import com.google.firebase.messaging.*;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FirebaseMessagingService {
    private final FcmTokenRepository fcmTokenRepository;

    public void saveFcmToken(UserFcmToken token) {
        fcmTokenRepository.save(token);
    }

    public String sendNotificationToAllUser(String title, String body) {
        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        Message message = Message.builder()
                .setTopic("all_users")
                .setNotification(notification)
                .build();

        try {
            return FirebaseMessaging.getInstance().send(message);
        } catch (Exception e) {
            e.printStackTrace();
            return "Error sending notification";
        }
    }

    public void sendNotificationToUser(Long userId, String title, String body) {
        UserFcmToken userFcmToken = fcmTokenRepository.findByUserId(userId);
        sendNotification(userFcmToken.getFcmToken(), title, body);
    }

    public String sendNotificationToFollowers(Long userId, String title, String body) {
        String topic = "user_" + userId;

        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        Message message = Message.builder()
                .setTopic(topic)
                .setNotification(notification)
                .build();

        try {
            return FirebaseMessaging.getInstance().send(message);
        } catch (Exception e) {
            e.printStackTrace();
            return "Error sending notification";
        }
    }

    public void sendNotificationToUsers(List<Long> userIdList, String title, String body) {
        List<UserFcmToken> userFcmToken = fcmTokenRepository.findByUserIdList(userIdList);
        sendNotificationToMultipleUsers(userFcmToken.stream()
                .map(UserFcmToken::getFcmToken)
                .collect(Collectors.toList()), title, body);
    }

    private String sendNotification(String fcmToken, String title, String body) {
        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        Message message = Message.builder()
                .setToken(fcmToken)
                .setNotification(notification)
                .build();

        try {
            return FirebaseMessaging.getInstance().send(message);
        } catch (Exception e) {
            e.printStackTrace();
            return "Error sending notification";
        }
    }

    private String sendNotificationToMultipleUsers(List<String> fcmTokens, String title, String body) {
        Notification notification = Notification.builder()
                .setTitle(title)
                .setBody(body)
                .build();

        MulticastMessage message = MulticastMessage.builder()
                .addAllTokens(fcmTokens)
                .setNotification(notification)
                .build();

        try {
            BatchResponse response = FirebaseMessaging.getInstance().sendMulticast(message);
            return "Successfully sent " + response.getSuccessCount() + " messages";
        } catch (Exception e) {
            e.printStackTrace();
            return "Error sending notification";
        }
    }
}
