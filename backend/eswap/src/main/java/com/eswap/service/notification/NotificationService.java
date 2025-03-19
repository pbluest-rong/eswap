package com.eswap.service.notification;

import com.eswap.common.constants.NotificationType;
import com.eswap.model.Notification;
import com.eswap.repository.NotificationRepository;
import lombok.RequiredArgsConstructor;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class NotificationService {

    private final NotificationRepository notificationRepository;
    private final RedisTemplate<String, Object> redisTemplate;

    // TTL cho thông báo TEMPORARY (30 ngày)
    private static final Duration TEMPORARY_TTL = Duration.ofDays(30);

    // Tạo thông báo mới
    public void createNotification(Long userId, String message, NotificationType type) {
        Notification notification = new Notification();
        notification.setUserId(userId);
        notification.setMessage(message);
        notification.setType(type);

        if (type == NotificationType.IMPORTANT) {
            // Lưu vào cả Redis và Database
            notificationRepository.save(notification);
            redisTemplate.opsForValue().set(getRedisKey(userId, notification.getId()), notification);
        } else {
            // Lưu vào Redis với TTL 30 ngày
            redisTemplate.opsForValue().set(getRedisKey(userId, notification.getId()), notification, TEMPORARY_TTL);
        }
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