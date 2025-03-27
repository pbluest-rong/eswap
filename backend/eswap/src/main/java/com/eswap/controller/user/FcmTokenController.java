package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.service.notification.FirebaseMessagingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/fcm")
@RequiredArgsConstructor
public class FcmTokenController {
    private final FirebaseMessagingService fcmService;

    @PostMapping("/save-token")
    public ResponseEntity<ApiResponse> saveToken(Authentication authentication, @RequestParam String fcmToken) {
        fcmService.saveFcmToken(authentication, fcmToken);
        fcmService.subscribeToTopic(fcmToken, "all_users");
        return ResponseEntity.ok(new ApiResponse(true, "Token saved successfully", null));
    }
}
