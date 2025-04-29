package com.eswap.service.notification;

import com.eswap.common.constants.NotificationType;
import com.eswap.model.User;
import com.eswap.model.UserFcmToken;
import com.eswap.repository.FcmTokenRepository;
import com.google.firebase.messaging.*;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;

import java.util.Collections;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class FirebaseMessagingService {
    private final FcmTokenRepository fcmTokenRepository;

    public void saveFcmToken(Authentication connectedUser, String fcmtoken) {
        User user = (User) connectedUser.getPrincipal();
        UserFcmToken fcmToken = fcmTokenRepository.findByFcmToken(fcmtoken);
        if (fcmToken == null) {
            UserFcmToken userFcmToken = new UserFcmToken();
            userFcmToken.setUserId(user.getId());
            userFcmToken.setFcmToken(fcmtoken);
            fcmTokenRepository.save(userFcmToken);
        }
    }

    public void removeToken(String fcmToken) {
        fcmTokenRepository.deleteByFcmToken(fcmToken);
    }

    public void removeAllTokensByUser(Long userId) {
        fcmTokenRepository.deleteByUserId(userId);
    }

    public String sendNotification(String fcmToken, String title, String body, String data) {
        Message message = buildMessage(fcmToken, null, title, body, data);
        return sendMessage(message);
    }

    public String sendNotificationToTopic(String topic, String title, String body, String data) {
        Message message = buildMessage(null, topic, title, body, data);
        return sendMessage(message);
    }

    private Message buildMessage(String fcmToken, String topic, String title, String body, String data) {
        Message.Builder messageBuilder = Message.builder()
                .setNotification(Notification.builder()
                        .setTitle(title)
                        .setBody(body)
                        .build());

        if (fcmToken != null && !fcmToken.isEmpty()) messageBuilder.setToken(fcmToken);
        if (topic != null && !topic.isEmpty()) messageBuilder.setTopic(topic);
        if (data != null && !data.isEmpty()) messageBuilder.putData("data", data);

        return messageBuilder.build();
    }

    private String sendMessage(Message message) {
        try {
            return FirebaseMessaging.getInstance().send(message);
        } catch (Exception e) {
//            e.printStackTrace();
            return "Error sending notification";
        }
    }

    public String subscribeToTopic(String token, String topic) {
        try {
            FirebaseMessaging.getInstance().subscribeToTopic(Collections.singletonList(token), topic);
            return "Token đã đăng ký thành công vào topic: " + topic;
        } catch (FirebaseMessagingException e) {
            return "Lỗi đăng ký vào topic: " + e.getMessage();
        }
    }

    public String unsubscribeFromTopic(String token, String topic) {
        try {
            FirebaseMessaging.getInstance().unsubscribeFromTopic(Collections.singletonList(token), topic);
            return "Token đã hủy đăng ký khỏi topic: " + topic;
        } catch (FirebaseMessagingException e) {
            return "Lỗi khi hủy đăng ký: " + e.getMessage();
        }
    }
}