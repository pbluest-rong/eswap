package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.response.AuthenticationResponse;
import com.eswap.response.FollowResponse;
import com.eswap.response.UserResponse;
import com.eswap.service.UserService;
import com.eswap.request.ChangeEmailRequest;
import com.eswap.request.ChangeInfoRequest;
import com.eswap.request.ChangePasswordRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("accounts")
@RequiredArgsConstructor
public class AccountController {
    private final UserService userService;

    @PostMapping("/auto-login")
    public ResponseEntity<ApiResponse> getLoginInfo(Authentication auth) {
        AuthenticationResponse authenticationResponse = userService.getLoginInfo(auth);
        return ResponseEntity.ok(
                new ApiResponse(true,
                        "Login Success",
                        authenticationResponse));
    }

    @PostMapping("/enable-account")
    public ResponseEntity<ApiResponse> enableUser(Authentication authentication) {
        userService.enableAccount(authentication);
        return ResponseEntity.ok(new ApiResponse(true, "Disable account successfully", null));
    }

    @PostMapping("/disable-account")
    public ResponseEntity<ApiResponse> disableUser(Authentication authentication) {
        userService.disableAccount(authentication);
        return ResponseEntity.ok(new ApiResponse(true, "Disable account successfully", null));
    }

    @PostMapping("/follow/{followeeUserId}")
    public ResponseEntity<ApiResponse> follow(Authentication authentication, @PathVariable("followeeUserId") long followeeUserId) {
        FollowResponse followResponse = userService.follow(authentication, followeeUserId);
        return ResponseEntity.ok(new ApiResponse(true, "Follow user successfully", followResponse));
    }

    @PostMapping("/unfollow/{followeeUserId}")
    public ResponseEntity<ApiResponse> unfollow(Authentication authentication, @PathVariable("followeeUserId") long followeeUserId) {
        userService.unfollow(authentication, followeeUserId);
        return ResponseEntity.ok(new ApiResponse(true, "Unfollow user successfully", null));
    }

    @PutMapping("/accept-follow/{followerUserId}")
    public ResponseEntity<ApiResponse> acceptFollow(Authentication authentication, @PathVariable("followerUserId") long followerUserId) {
        FollowResponse followResponse = userService.acceptFollow(authentication, followerUserId);
        return ResponseEntity.ok(new ApiResponse(true, "Follow user successfully", followResponse));
    }

    @PostMapping("/remove-follow/{followerUserId}")
    public ResponseEntity<ApiResponse> removeFollow(Authentication authentication, @PathVariable("followerUserId") long followerUserId) {
        userService.removeFollow(authentication, followerUserId);
        return ResponseEntity.ok(new ApiResponse(true, "Unfollow user successfully", null));
    }

    @PostMapping("/update-avatar")
    public ResponseEntity<ApiResponse> updateAvatar(Authentication auth, @RequestParam("image") MultipartFile image) {
        String avatarUrl = userService.updateAvatar(auth, image);
        return ResponseEntity.ok(new ApiResponse(true, "Avatar updated successfully", avatarUrl));
    }

    @PostMapping("/delete-avatar")
    public void deleteAvatar(Authentication auth) {
        userService.deleteAvatar(auth);
    }

    @PostMapping("/change-pw")
    public ResponseEntity<ApiResponse> changePassword(Authentication authentication, @RequestBody ChangePasswordRequest request) {
        userService.changePassword(authentication, request);
        return ResponseEntity.ok(new ApiResponse(true, "Change password successfully", null));
    }

    @PostMapping("/change-email")
    public ResponseEntity<ApiResponse> changeEmail(Authentication authentication, @RequestBody ChangeEmailRequest request) {
        userService.changeEmail(authentication, request);
        return ResponseEntity.ok(new ApiResponse(true, "Change email successfully", null));
    }

    @PutMapping("/change-info")
    public ResponseEntity<ApiResponse> changeInfo(Authentication authentication, @RequestBody ChangeInfoRequest request) {
        AuthenticationResponse userResponse = userService.changeInformation(authentication, request);
        return ResponseEntity.ok(new ApiResponse(true, "Change information successfully", userResponse));
    }
}
