package com.eswap.service;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.exception.*;
import com.eswap.common.security.JwtService;
import com.eswap.model.EducationInstitution;
import com.eswap.repository.*;
import com.eswap.request.AuthenticationRequest;
import com.eswap.request.ForgotPasswordRequest;
import com.eswap.request.RefreshTokenRequest;
import com.eswap.request.ResgistrationRequest;
import com.eswap.response.AuthenticationResponse;
import com.eswap.model.OTP;
import com.eswap.model.User;
import com.google.firebase.auth.FirebaseAuth;
import com.google.firebase.auth.FirebaseToken;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.*;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class AuthenticationService {
    private final RoleRepository roleRepository;
    private final PasswordEncoder passwordEncoder;
    private final UserRepository userRepository;
    private final OTPRepository otpRepository;
    private final EmailService emailService;
    private final AuthenticationManager authenticationManager;
    private final JwtService jwtService;
    private final EducationInstitutionRepository educationInstitutionRepository;
    private final UserDetailsService userDetailsService;
    private final NotificationRepository notificationRepository;
    private final MessageRepository messageRepository;

    private boolean existsUser(String usernameEmailPhoneNumber) {
        return User.isValidUsername(usernameEmailPhoneNumber) ?
                userRepository.existsByUsername(usernameEmailPhoneNumber) :
                (User.isValidEmail(usernameEmailPhoneNumber)) ?
                        userRepository.existsByEmail(usernameEmailPhoneNumber) :
                        userRepository.existsByPhoneNumber(usernameEmailPhoneNumber);
    }

    /*
    1. Register
     */
    @Transactional
    public User register(ResgistrationRequest request) {
        var userRole = roleRepository.findByName("USER")
                .orElseThrow(() -> new IllegalArgumentException("ROLE USER was not initialized"));
        return Optional.of(request)
                .filter(user -> (
                                !existsUser(request.getEmailPhoneNumber())
                        )
                )
                .map(req -> {
                    Optional<OTP> optionalToken = otpRepository.findByUsernameEmailPhoneNumber(request.getEmailPhoneNumber());

                    if (optionalToken.isPresent() &&
                            optionalToken.get().getExpiresAt().isAfter(LocalDateTime.now()) && request.getOtp().equals(optionalToken.get().getOtp())) {

                        EducationInstitution eduInstitution = educationInstitutionRepository.findById(request.getEducationInstitutionId()).orElseThrow(() -> new IllegalArgumentException("EDUCATION INSTITUTION ID was not initialized"));
                        User user = User.builder()
                                .firstName(request.getFirstname())
                                .lastName(request.getLastname())
                                .educationInstitution(eduInstitution)
                                .dob(request.getDob())
                                .gender(request.getGender())
                                .email(request.getEmailPhoneNumber())
                                .password(passwordEncoder.encode(request.getPassword()))
                                .accountLocked(false)
                                .enabled(true)
                                .role(userRole)
                                .build();
                        ;
                        otpRepository.deleteByUsernameEmailPhoneNumber(request.getEmailPhoneNumber());
                        return userRepository.save(user);
                    } else {
                        throw new CodeInvalidException(AppErrorCode.AUTH_INVALID_CODE);
                    }
                })
                .orElseThrow(() -> new AlreadyExistsException(AppErrorCode.USER_EXISTS, "email", request.getEmailPhoneNumber()));
    }

    public User registerUsePhoneNumber(String token, @Valid ResgistrationRequest request) {
        try {
            // Lấy ID Token từ header
            String idToken = token.replace("Bearer ", "");
            // Xác thực ID Token với Firebase
            FirebaseToken decodedToken = FirebaseAuth.getInstance().verifyIdToken(idToken);
            var userRole = roleRepository.findByName("USER")
                    .orElseThrow(() -> new IllegalArgumentException("ROLE USER was not initialized"));
            return Optional.of(request)
                    .filter(user -> (
                                    !existsUser(request.getEmailPhoneNumber())
                            )
                    )
                    .map(req -> {
                        EducationInstitution eduInstitution = educationInstitutionRepository.findById(request.getEducationInstitutionId()).orElseThrow(() -> new IllegalArgumentException("EDUCATION INSTITUTION ID was not initialized"));
                        User user = User.builder()
                                .firstName(request.getFirstname())
                                .lastName(request.getLastname())
                                .educationInstitution(eduInstitution)
                                .dob(request.getDob())
                                .gender(request.getGender())
                                .phoneNumber(request.getEmailPhoneNumber())
                                .password(passwordEncoder.encode(request.getPassword()))
                                .accountLocked(false)
                                .enabled(true)
                                .role(userRole)
                                .build();
                        ;
                        otpRepository.deleteByUsernameEmailPhoneNumber(request.getEmailPhoneNumber());
                        return userRepository.save(user);
                    })
                    .orElseThrow(() -> new AlreadyExistsException(AppErrorCode.USER_EXISTS, "phone number", request.getEmailPhoneNumber()));
        } catch (Exception e) {
            e.printStackTrace();
            throw new InvalidCredentialsException(AppErrorCode.USER_INVALID_CREDENTIALS);
        }
    }

    /**
     * 3. login, authenticate -> jwtToken
     */
    public AuthenticationResponse authenticate(AuthenticationRequest request) {
        String username;
        User info;
        if (User.isValidEmail(request.getUsernameEmailPhoneNumber())) {
            info = userRepository.findByEmail(request.getUsernameEmailPhoneNumber()).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "email", request.getUsernameEmailPhoneNumber()));

        } else if (User.isValidPhoneNumber(request.getUsernameEmailPhoneNumber())) {
            info = userRepository.findByPhoneNumber(request.getUsernameEmailPhoneNumber()).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "phone number", request.getUsernameEmailPhoneNumber()));
        } else {
            info = userRepository.findByUsername(request.getUsernameEmailPhoneNumber()).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "username", request.getUsernameEmailPhoneNumber()));
        }
        username = info.getUsername();
        try {
            var auth = authenticationManager.authenticate(
                    new UsernamePasswordAuthenticationToken(
                            username,
                            request.getPassword()
                    )
            );
            var claims = new HashMap<String, Object>();
            var user = (User) auth.getPrincipal();

            var jwtToken = jwtService.generateToken(claims, user);
            var refreshToken = jwtService.generateRefreshToken(user);

            int unreadNotificationNumber = notificationRepository.countUnreadByRecipientId(user.getId());
            int unreadMessageNumber = messageRepository.countUnreadMessagesForUser(user.getId());
            return AuthenticationResponse.builder()
                    .accessToken(jwtToken)
                    .refreshToken(refreshToken)
                    .userId(info.getId())
                    .username(info.getUsername())
                    .avatarUrl(info.getAvatarUrl())
                    .firstName(info.getFirstName())
                    .lastName(info.getLastName())
                    .role(info.getRole().getName())
                    .educationInstitutionId(info.getEducationInstitution().getId())
                    .educationInstitutionName(info.getEducationInstitution().getName())
                    .unreadNotificationNumber(unreadNotificationNumber)
                    .unreadMessageNumber(unreadMessageNumber)
                    .build();
        } catch (BadCredentialsException ex) {
            throw new InvalidCredentialsException(AppErrorCode.USER_INVALID_CREDENTIALS);
        } catch (LockedException ex) {
            throw new AccountLockedException(AppErrorCode.USER_LOCKED);
        }
    }

    /**
     * 4 verify forgot password
     */
    public AuthenticationResponse verifyForgotPw(String emailPhoneNumber, String otp) {
        String username;
        if (User.isValidEmail(emailPhoneNumber)) {
            System.out.println("email: " + emailPhoneNumber);
            User user = userRepository.findByEmail(emailPhoneNumber).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "emailPhoneNumber", emailPhoneNumber));
            username = user.getUsername();
        } else if (User.isValidPhoneNumber(emailPhoneNumber)) {
            System.out.println("phone number: " + emailPhoneNumber);
            User user = userRepository.findByPhoneNumber(emailPhoneNumber).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "emailPhoneNumber", emailPhoneNumber));
            username = user.getUsername();
        } else
            username = emailPhoneNumber;

        Optional<OTP> optionalOTP = otpRepository.findByUsernameEmailPhoneNumber(emailPhoneNumber);
        if (optionalOTP.isPresent() &&
                optionalOTP.get().getExpiresAt().isAfter(LocalDateTime.now()) && otp.equals(optionalOTP.get().getOtp())) {
            otpRepository.deleteByUsernameEmailPhoneNumber(emailPhoneNumber);
            String token = jwtService.generateTemporaryToken(username);
            return AuthenticationResponse.builder().accessToken(token).build();
        } else {
            throw new CodeInvalidException(AppErrorCode.AUTH_INVALID_CODE);
        }
    }

    /**
     * 5 forgor password
     */
    public void forgotPassword(ForgotPasswordRequest request) {
        if (!jwtService.isTemporaryTokenValid(request.getToken())) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }
        String username = jwtService.extractUserName(request.getToken());
        User user = userRepository.findByUsername(username).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "username", username));
        user.setPassword(passwordEncoder.encode(request.getNewPassword()));
        userRepository.save(user);
    }

    public boolean checkExistUsernameEmailPhoneNumber(String usernameEmailPhoneNumber) {
        return existsUser(usernameEmailPhoneNumber);
    }

    public AuthenticationResponse refreshToken(RefreshTokenRequest request) {
        String refreshToken = request.getRefreshToken();
        String username = jwtService.extractUserName(refreshToken);

        if (username != null) {
            UserDetails userDetails = userDetailsService.loadUserByUsername(username);
            // Validate the refresh token
            if (jwtService.isTokenValid(refreshToken, userDetails)) {
                // Generate new access token
                Map<String, Object> claims = new HashMap<>();

                String newAccessToken = jwtService.generateToken(claims, userDetails);

                return AuthenticationResponse.builder()
                        .accessToken(newAccessToken)
                        .refreshToken(refreshToken)
                        .build();
            }
        }
        throw new InvalidTokenException(AppErrorCode.AUTH_TOKEN_EXPRIED);
    }

}
