package com.ecoswap.features.auth;

import com.ecoswap.common.exception.AccountLockedException;
import com.ecoswap.common.exception.AlreadyExistsException;
import com.ecoswap.common.exception.CodeInvalidException;
import com.ecoswap.common.exception.UserNotEnabledException;
import com.ecoswap.common.security.JwtService;
import com.ecoswap.features.mail.EmailService;
import com.ecoswap.features.role.RoleRepository;
import com.ecoswap.features.user.CodeToken;
import com.ecoswap.features.user.CodeTokenRepository;
import com.ecoswap.features.user.User;
import com.ecoswap.features.user.UserRepository;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.actuate.health.HealthContributor;
import org.springframework.security.authentication.*;
import org.springframework.security.core.AuthenticationException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthenticationService {
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final CodeTokenRepository tokenRepository;
    private final EmailService emailService;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final HealthContributor mailHealthContributor;

    /*
    1. Register
     */
    @Transactional
    public User register(ResgistrationRequest request) {
        var userRole = roleRepository.findByName("USER")
                .orElseThrow(() -> new IllegalArgumentException("ROLE USER was not initialized"));
        return Optional.of(request)
                .filter(user -> !userRepository.existsByEmail(request.getEmail()))
                .map(req -> {
                    Optional<CodeToken> optionalToken = tokenRepository.findByUserEmail(request.getEmail());
                    if (optionalToken.isPresent() &&
                            optionalToken.get().getExpiresAt().isAfter(LocalDateTime.now()) &&
                            optionalToken.get().getValidatedAt() == null) {
                        User user = User.builder()
                                .firstName(request.getFirstname())
                                .lastName(request.getLastname())
                                .dob(request.getDob())
                                .gender(request.getGender())
                                .email(request.getEmail())
                                .password(passwordEncoder.encode(request.getPassword()))
                                .accountLocked(false)
                                .enabled(true)
                                .role(userRole)
                                .build();
                        ;
                        tokenRepository.deleteByEmail(request.getEmail());
                        return userRepository.save(user);
                    } else {
                        throw new CodeInvalidException("Mã xác thực sai hoặc đã hết hạn!");
                    }
                })
                .orElseThrow(() -> new AlreadyExistsException("Oops! " + request.getEmail() + " already exists"));
    }

    /**
     * 2. activate email -> save code token -> send mail
     */
    public void sentCodeTokenToRegister(String email) {
        String generatedToken = generateActivationCode(6);

        Optional<CodeToken> codeToken = tokenRepository.findByUserEmail(email);
        CodeToken token;
        if (codeToken.isPresent()) {
            token = codeToken.get();
            token.setToken(generatedToken);
            token.setCreatedAt(LocalDateTime.now());
            token.setExpiresAt(LocalDateTime.now().plusMinutes(2));
        } else {
            token = CodeToken.builder()
                    .token(generatedToken)
                    .createdAt(LocalDateTime.now())
                    .expiresAt(LocalDateTime.now().plusMinutes(2))
                    .email(email)
                    .build();
        }
        tokenRepository.save(token);
        String htmlContent = emailService.buildVerificationEmail(token.getToken());
        try {
            emailService.sendMail(email, "Xác thực Email!", htmlContent);
        } catch (MessagingException e) {
            throw new RuntimeException(e);
        }
    }

    private String generateActivationCode(int length) {
        String characters = "0123456789";
        StringBuilder code = new StringBuilder();
        SecureRandom secureRandom = new SecureRandom();
        for (int i = 0; i < length; i++) {
            int randomIndex = secureRandom.nextInt(characters.length());
            code.append(randomIndex);
        }
        return code.toString();
    }

    /**
     * 3. login, authenticate -> jwtToken
     */
    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        try {
            var auth = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            request.getEmail(),
                            request.getPassword()
                    )
            );
            var claims = new HashMap<String, Object>();
            var user = (User) auth.getPrincipal();
            claims.put("fullName", user.getFullName());
            var jwtToken = jwtService.generateToken(claims, user);
            return AuthenticationResponse.builder()
                    .token(jwtToken).build();
        } catch (BadCredentialsException ex) {
            throw new BadCredentialsException("Email hoặc mật khẩu không đúng!");
        } catch (DisabledException ex) {
            throw new UserNotEnabledException("Tài khoản chưa được kích hoạt!");
        } catch (LockedException ex) {
            throw new AccountLockedException("Tài khoản đã bị khóa!");
        } catch (AuthenticationException ex) {
            throw new RuntimeException("Xác thực thất bại: " + ex.getMessage());
        }
    }

}
