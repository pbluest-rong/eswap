package com.eswap.controller.user;

import com.eswap.model.UserFcmToken;
import com.eswap.service.fcm.FirebaseMessagingService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/fcm")
@RequiredArgsConstructor
public class FcmTokenController {
    private final FirebaseMessagingService fcmService;

    @PostMapping("/save-token")
    public ResponseEntity<String> saveToken(@RequestBody UserFcmToken token) {
        fcmService.saveFcmToken(token);
        return ResponseEntity.ok("Token saved successfully");
    }
}
