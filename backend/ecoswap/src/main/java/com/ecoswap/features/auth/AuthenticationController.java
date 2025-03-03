package com.ecoswap.features.auth;

import com.ecoswap.common.ApiResponse;
import com.ecoswap.features.mail.EmailService;
import com.ecoswap.features.user.User;
import io.swagger.v3.oas.annotations.tags.Tag;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("auth")
@RequiredArgsConstructor
@Tag(name = "Authentication")
public class AuthenticationController {
    private final AuthenticationService authenticationService;
    private final EmailService emailService;


    @GetMapping("/require-activate-email")
    public void require(@RequestParam @Email(message = "Email is not formatted")
                        @NotEmpty(message = "Email is mandatory") String email) {
        authenticationService.sentCodeTokenToRegister(email);
    }

    @PostMapping("register")
    public ResponseEntity<ApiResponse> register(@RequestBody @Valid ResgistrationRequest request) {
        try {
            User user = authenticationService.register(request);
            return ResponseEntity.ok(new ApiResponse("User registered successfully", null));
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    @PostMapping("authenticate")
    public ResponseEntity<ApiResponse> authenticate(@RequestBody @Valid AuthenticationRequest request) {
        return ResponseEntity.ok(new ApiResponse("User authenticated successfully", authenticationService.authenticate(request)));
    }
}