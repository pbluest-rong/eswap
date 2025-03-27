package com.eswap.service.notification;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.constants.NotificationCategory;
import com.eswap.common.constants.NotificationType;
import com.eswap.common.constants.RecipientType;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.model.Follow;
import com.eswap.model.Notification;
import com.eswap.model.User;
import com.eswap.model.UserFcmToken;
import com.eswap.repository.FcmTokenRepository;
import com.eswap.repository.FollowRepository;
import com.eswap.repository.NotificationRepository;
import com.eswap.repository.UserRepository;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {
    private final NotificationRepository notificationRepository;
    private final FollowRepository followRepository;
    private final FcmTokenRepository fcmTokenRepository;
    private final RedisTemplate<String, Object> redisTemplate;
    private final FirebaseMessagingService firebaseMessagingService;
    private final UserRepository userRepository;

    // TTL cho thông báo TEMPORARY (30 ngày)
    private static final Duration TEMPORARY_TTL = Duration.ofDays(30);

    // Tạo thông báo mới
    public Notification createAndPushNotification(
            Long userId,
            RecipientType recipientType,
            NotificationCategory category,
            NotificationType type,
            String title,
            String message,
            Long recipientIdForINDIVIDUAL
    ) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setRecipientType(recipientType);
        notification.setCategory(category);
        notification.setType(type);
        notification.setTitle(title);
        notification.setMessage(message);

        if (type == NotificationType.IMPORTANT) {
            // Lưu vào cả Redis và Database
            notificationRepository.save(notification);
            redisTemplate.opsForValue().set(getRedisKey(userId, notification.getId()), notification);
        } else {
            // Lưu vào Redis với TTL 30 ngày
            redisTemplate.opsForValue().set(getRedisKey(userId, notification.getId()), notification, TEMPORARY_TTL);
        }
        // Chuyển thành JSON
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            String notificationJson = objectMapper.writeValueAsString(notification);
            // Gửi thông báo
            switch (notification.getRecipientType()) {
                case INDIVIDUAL:
                    if (recipientIdForINDIVIDUAL != null) notification.setRecipientId(recipientIdForINDIVIDUAL);
                    List<UserFcmToken> userFcmTokenList = fcmTokenRepository.findByUserId(notification.getRecipientId());
                    for (UserFcmToken userFcmToken : userFcmTokenList)
                        firebaseMessagingService.sendNotification(userFcmToken.getFcmToken(), notification.getTitle(), notificationJson, notification.getType(), "data");
                    break;
                case FOLLOWERS:
                    User user = userRepository.findById(userId)
                            .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", userId));
//                    List<User> recipientList = followRepository.findFollowersByUserId(user.getId());
//                    List<Long> recipientIdList = recipientList.stream()
//                            .map(User::getId)
//                            .collect(Collectors.toList());
//                    List<UserFcmToken> userFcmTokens = fcmTokenRepository.findByUserIdList(recipientIdList);
                    firebaseMessagingService.sendNotificationToTopic("follow_"+user.getId(), notification.getTitle(), notificationJson, notification.getType(), "data");
                    break;
                case ALL_USERS:
                    firebaseMessagingService.sendNotificationToTopic("all_users", notification.getTitle(), notificationJson, notification.getType(), "data");
                    break;
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
        return notification;
    }

    // Lấy thông báo từ Redis, nếu không có thì lấy từ Database
    public List<Notification> getUserNotifications(Long userId) {
        String redisPattern = "notification:" + userId + ":*";
        List<Object> notifications = redisTemplate.opsForValue().multiGet(redisTemplate.keys(redisPattern));

        if (notifications != null && !notifications.isEmpty()) {
            return (List<Notification>) (Object) notifications;
        }
        return notificationRepository.findByUserIdOrderByCreatedAtDesc(userId);
    }

    // Đánh dấu thông báo đã đọc
    public void markAsRead(Long notificationId) {
        Optional<Notification> notificationOpt = notificationRepository.findById(notificationId);
        notificationOpt.ifPresent(notification -> {
            notification.setRead(true);
            notificationRepository.save(notification);

            // Cập nhật Redis
            String redisKey = getRedisKey(notification.getUserId(), notificationId);
            redisTemplate.opsForValue().set(redisKey, notification);
        });
    }

    // Xóa thông báo tạm thời sau TTL
    public void deleteExpiredNotifications() {
        redisTemplate.keys("notification:*").forEach(redisTemplate::delete);
    }

    private String getRedisKey(Long userId, Long notificationId) {
        return "notification:" + userId + ":" + notificationId;
    }
}