package com.eswap.controller.publish;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.repository.UserRepository;
import com.eswap.request.*;
import com.eswap.response.AuthenticationResponse;
import com.eswap.response.OTPResponse;
import com.eswap.response.UserResponse;
import com.eswap.service.OTPService;
import com.eswap.model.User;
import com.eswap.service.AuthenticationService;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.NotEmpty;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("auth")
@RequiredArgsConstructor
@Tag(name = "Authentication")
public class AuthenticationController {
    private final AuthenticationService authenticationService;
    private final OTPService otpService;
    private final UserRepository userRepository;

    @PostMapping("/require-activate")
    public ResponseEntity<ApiResponse> requireActivateEmail(
            @RequestParam
            @NotEmpty(message = "Email or phone number is mandatory") String emailPhoneNumber) {
        OTPResponse otpResponse = otpService.sendCodeToken(emailPhoneNumber, 10);
        return ResponseEntity.ok(new ApiResponse(true, "Activation email sent successfully.", otpResponse));
    }

    @GetMapping("/stores")
    public ResponseEntity<ApiResponse> getStore() {
        List<User> stores = userRepository.getStores();
        List<UserResponse> usersResponse = stores.stream().map(u -> UserResponse.mapperToUserResponse(u, null, false, false)).toList();
        return ResponseEntity.ok(new ApiResponse(true, "Store list retrieved successfully.", usersResponse));
    }

    @PostMapping("/register-email")
    public ResponseEntity<ApiResponse> register(@RequestBody @Valid ResgistrationRequest request) {
        authenticationService.register(request);
        return ResponseEntity.ok(new ApiResponse(true, "User registered successfully", null));
    }

    @PostMapping("/register-phone")
    public ResponseEntity<ApiResponse> signup(@RequestHeader("Authorization") String token,
                                              @RequestBody @Valid ResgistrationRequest request) {
        authenticationService.registerUsePhoneNumber(token, request);
        return ResponseEntity.ok(new ApiResponse(true, "User registered successfully", null));

    }

    @PostMapping("/login")
    public ResponseEntity<ApiResponse> authenticate(@RequestBody @Valid AuthenticationRequest request) {
        return ResponseEntity.ok(new ApiResponse(true, "User authenticated successfully", authenticationService.authenticate(request)));
    }

    @PostMapping("/require-forgotpw")
    public ResponseEntity<ApiResponse> requireForgotPw(
            @RequestParam
            @NotEmpty(message = "Username or email or phone number is mandatory") String emailPhoneNumber) {
        if (User.isValidEmail(emailPhoneNumber)) {
            userRepository.findByEmail(emailPhoneNumber).orElseThrow(()
                    -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "email", emailPhoneNumber));

        } else if (User.isValidPhoneNumber(emailPhoneNumber)) {
            userRepository.findByPhoneNumber(emailPhoneNumber).orElseThrow(()
                    -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "phone number", emailPhoneNumber));
        } else {
            new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "email or phone number", emailPhoneNumber);
        }
        OTPResponse codeTokenResponse = otpService.sendCodeToken(emailPhoneNumber, 10);
        return ResponseEntity.ok(new ApiResponse(true, "Activation email sent successfully.", codeTokenResponse));
    }

    @PostMapping("/verify-forgotpw")
    public ResponseEntity<ApiResponse> verifyForgotPw(@RequestHeader(value = "Authorization", required = false) String token,
                                                      @RequestBody VerifyForgotPassword verifyForgotPassword) {
        AuthenticationResponse authenticationResponse = authenticationService.verifyForgotPw(token, verifyForgotPassword.getEmailPhoneNumber(), verifyForgotPassword.getOtp());
        return ResponseEntity.ok(new ApiResponse(true, "OTP verified successfully.", authenticationResponse));
    }


    @PostMapping("/forgotpw")
    public ResponseEntity<ApiResponse> forgotPassword(@RequestBody @Valid ForgotPasswordRequest request) {
        authenticationService.forgotPassword(request);
        return ResponseEntity.ok(new ApiResponse(true, "User forgot password successfully", null));
    }

    @PostMapping("/check-exist")
    public ResponseEntity<ApiResponse> checkExistEmail(
            @RequestParam
            @NotEmpty(message = "Username or email or phone number is mandatory") String usernameEmailPhoneNumber) {
        try {
            boolean exists = authenticationService.checkExistUsernameEmailPhoneNumber(usernameEmailPhoneNumber);
            Map<String, Boolean> result = new HashMap<>();
            result.put("isExist", exists);

            return ResponseEntity.ok(new ApiResponse(true, exists ? "Email already exists" : "Email is available", result));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(new ApiResponse(false, "Internal server error", null));
        }
    }

    @PostMapping("/refresh-token")
    public AuthenticationResponse refreshToken(@RequestBody RefreshTokenRequest request) {
        return authenticationService.refreshToken(request);
    }
}