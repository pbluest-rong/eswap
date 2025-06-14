package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.PageResponse;
import com.eswap.response.NotificationResponse;
import com.eswap.service.notification.FirebaseMessagingService;
import com.eswap.service.notification.NotificationService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("notifications")
@RequiredArgsConstructor
public class NotificationController {
    private final FirebaseMessagingService fcmService;
    private final NotificationService notificationService;

    @PostMapping("/save-fcm-token")
    public ResponseEntity<ApiResponse> saveToken(Authentication authentication, @RequestParam String fcmToken) {
        fcmService.saveFcmToken(authentication, fcmToken);
        fcmService.subscribeToTopic(fcmToken, "all_users");
        return ResponseEntity.ok(new ApiResponse(true, "Token saved successfully", null));
    }

    @DeleteMapping("/remove-fcm-token")
    public void removeFcmToken(@RequestParam String fcmToken){
        fcmService.removeToken(fcmToken);
    }

    @GetMapping
    public ResponseEntity<ApiResponse> getNotifications(
            Authentication auth,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        PageResponse<NotificationResponse> notifications = notificationService.getNotifications(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Notifications", notifications));
    }

    @PutMapping("/{notificationId}")
    public void markAsRead(@PathVariable("notificationId") Long notificationId, Authentication auth) {
        notificationService.markAsRead(notificationId);
    }

    @GetMapping("count-unread")
    public ResponseEntity<ApiResponse> countUnreadNotifications(Authentication auth) {
        return ResponseEntity.ok(new ApiResponse(true, "countUnreadNotifications", notificationService.countUnreadNotifications(auth)));
    }
}
