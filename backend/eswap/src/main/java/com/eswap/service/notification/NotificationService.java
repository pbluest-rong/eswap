package com.eswap.service.notification;

import com.eswap.common.constants.*;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.model.Follow;
import com.eswap.model.Notification;
import com.eswap.model.User;
import com.eswap.model.UserFcmToken;
import com.eswap.repository.FcmTokenRepository;
import com.eswap.repository.FollowRepository;
import com.eswap.repository.NotificationRepository;
import com.eswap.repository.UserRepository;
import com.eswap.response.NotificationResponse;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.data.redis.core.RedisTemplate;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.Duration;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.stream.Collector;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class NotificationService {
    private final NotificationRepository notificationRepository;
    private final FollowRepository followRepository;
    private final FcmTokenRepository fcmTokenRepository;
    private final FirebaseMessagingService firebaseMessagingService;
    private final UserRepository userRepository;

    @Async
    public void createAndPushNotification(
            Long senderId,
            RecipientType recipientType,
            NotificationCategory category,
            NotificationType type,
            String title,
            String message,
            Long postId,
            Long recipientIdForINDIVIDUAL
    ) {
        User senderUser = userRepository.findById(senderId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", senderId));

        Notification notification = new Notification();
        notification.setSenderId(senderId);
        notification.setSenderRole(senderUser.getRole().getName());
        notification.setRecipientType(recipientType);
        notification.setCategory(category);
        notification.setType(type);
        notification.setTitle(title);
        notification.setMessage(message);
        notification.setPostId(postId);
        notification.setRecipientId(recipientIdForINDIVIDUAL);
        if (notification.getCategory() != NotificationCategory.NEW_MESSAGE)
            notificationRepository.save(notification);
        // send notification
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.registerModule(new JavaTimeModule());
            String notificationJson = objectMapper.writeValueAsString(notification);
            switch (notification.getRecipientType()) {
                case INDIVIDUAL:
                    List<UserFcmToken> userFcmTokenList = fcmTokenRepository.findByUserId(notification.getRecipientId());
                    for (UserFcmToken userFcmToken : userFcmTokenList) {
                        firebaseMessagingService.sendNotification(userFcmToken.getFcmToken(), notification.getTitle(), null, notificationJson);
                    }
                    break;
                case FOLLOWERS:
                    User user = userRepository.findById(senderUser.getId())
                            .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", senderUser.getId()));
                    List<User> recipientList = followRepository.findFollowersByUserId(user.getId());
                    List<Long> recipientIdList = recipientList.stream()
                            .map(User::getId)
                            .collect(Collectors.toList());
                    List<UserFcmToken> userFcmTokens = fcmTokenRepository.findByUserIdList(recipientIdList);
                    for (UserFcmToken userFcmToken : userFcmTokens) {
                        firebaseMessagingService.sendNotification(userFcmToken.getFcmToken(), notification.getTitle(), null, notificationJson);
                    }
                    break;
                case ALL_USERS:
                    firebaseMessagingService.sendNotificationToTopic("all_users", notification.getTitle(), null, notificationJson);
                    break;
            }
        } catch (JsonProcessingException e) {
            throw new RuntimeException(e);
        }
    }

    @Transactional
    public void markAsRead(Long notificationId) {
        Optional<Notification> notificationOpt = notificationRepository.findById(notificationId);
        notificationOpt.ifPresent(notification -> {
            if (notification.getCategory() == NotificationCategory.NEW_MESSAGE) {
                notificationRepository.deleteById(notificationId);
            } else {
                notification.setRead(true);
                notificationRepository.save(notification);
            }
        });
    }


    public PageResponse<NotificationResponse> getNotifications(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size);
        Page<Notification> notifications = notificationRepository.getNotifications(user.getId(), pageable);
        List<NotificationResponse> notificationsList =
                notifications
                        .stream()
                        .map(
                                notification -> {
                                    User sender = userRepository.findById(notification.getSenderId()).orElse(null);
                                    String role = sender != null ? sender.getRole().getName() : "ADMIN";
                                    String firstName = sender != null ? sender.getFirstName() : "";
                                    String lastName = sender != null ? sender.getLastName() : "";
                                    String avatarUrl = sender != null ? sender.getAvatarUrl() : null;
                                    return NotificationResponse.builder()
                                            .id(notification.getId())
                                            .senderId(notification.getSenderId())
                                            .senderFirstName(firstName)
                                            .senderLastName(lastName)
                                            .senderRole(role)
                                            .category(notification.getCategory().name())
                                            .type(notification.getType().name())
                                            .read(notification.isRead())
                                            .postId(notification.getPostId())
                                            .createdAt(notification.getCreatedAt())
                                            .avatarUrl(avatarUrl)
                                            .build();
                                }
                        ).collect(Collectors.toList());
        return new PageResponse<>(
                notificationsList,
                notifications.getNumber(),
                notifications.getSize(),
                (int) notifications.getTotalElements(),
                notifications.getTotalPages(),
                notifications.isFirst(),
                notifications.isLast());
    }

    public int countUnreadNotifications(Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        return notificationRepository.countUnreadByRecipientId(user.getId());
    }
}