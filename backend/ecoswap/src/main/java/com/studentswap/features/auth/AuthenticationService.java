package com.studentswap.features.auth;

import com.studentswap.common.enums.RoleType;
import com.studentswap.common.security.JwtService;
import com.studentswap.features.mail.EmailService;
import com.studentswap.features.role.RoleRepository;
import com.studentswap.features.user.CodeToken;
import com.studentswap.features.user.CodeTokenRepository;
import com.studentswap.features.user.User;
import com.studentswap.features.user.UserRepository;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

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
    @Value("${spring.application.mailing.frontend.activation-url}")
    private String activationUrl;

    /*
    1. Register
     */
    public boolean register(ResgistrationRequest request) throws MessagingException {
        Optional<CodeToken> optionalToken = tokenRepository.findByUserEmail(request.getEmail());

        if (optionalToken.isPresent() &&
                optionalToken.get().getExpiresAt().isAfter(LocalDateTime.now()) &&
                optionalToken.get().getValidatedAt() == null) {
            var userRole = roleRepository.findByName(RoleType.USER.name())
                    .orElseThrow(() -> new IllegalArgumentException("ROLE USER was not initialized"));
            var user = User.builder()
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
            userRepository.save(user);
            tokenRepository.deleteByEmail(request.getEmail());
            return true;
        }
        return false;
    }

    /**
     * 2. activate email -> save code token -> send mail
     */
    public void sentCodeTokenToRegister(String email) throws MessagingException {
        Optional<CodeToken> codeToken = tokenRepository.findByUserEmail(email);
        if (codeToken.isPresent()) {
            String generatedToken = generateActivationCode(6);
            CodeToken token = codeToken.get();
            token.setToken(generatedToken);
            token.setCreatedAt(LocalDateTime.now());
            token.setExpiresAt(LocalDateTime.now().plusMinutes(1));
            tokenRepository.save(token);
        } else {
            generateAndSaveActivationToken(email);
        }
    }

    //  generate token -> save activation token
    private String generateAndSaveActivationToken(String email) {
        String generatedToken = generateActivationCode(6);
        var token = CodeToken.builder()
                .token(generatedToken)
                .createdAt(LocalDateTime.now())
                .expiresAt(LocalDateTime.now().plusMinutes(1))
                .email(email)
                .build();
        tokenRepository.save(token);
        return generatedToken;
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
    public AuthenticationResponse authenticate(AuthenticationRequest request){
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
    }
}
