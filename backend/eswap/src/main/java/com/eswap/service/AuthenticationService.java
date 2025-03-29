package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.exception.*;
import com.eswap.common.security.JwtService;
import com.eswap.model.EducationInstitution;
import com.eswap.repository.EducationInstitutionRepository;
import com.eswap.request.AuthenticationRequest;
import com.eswap.request.ForgotPasswordRequest;
import com.eswap.request.RefreshTokenRequest;
import com.eswap.request.ResgistrationRequest;
import com.eswap.response.AuthenticationResponse;
import com.eswap.repository.RoleRepository;
import com.eswap.model.OTP;
import com.eswap.repository.OTPRepository;
import com.eswap.model.User;
import com.eswap.repository.UserRepository;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.*;
import org.springframework.security.core.userdetails.UserDetails;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

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
                                !existsUser(request.getUsernameEmailPhoneNumber())
                        )
                )
                .map(req -> {
                    Optional<OTP> optionalToken = otpRepository.findByUsernameEmailPhoneNumber(request.getUsernameEmailPhoneNumber());

                    if (optionalToken.isPresent() &&
                            optionalToken.get().getExpiresAt().isAfter(LocalDateTime.now()) && request.getOtp().equals(optionalToken.get().getOtp())) {

                        EducationInstitution eduInstitution = educationInstitutionRepository.findById(request.getEducationInstitutionId()).orElseThrow(() -> new IllegalArgumentException("EDUCATION INSTITUTION ID was not initialized"));
                        User user = User.builder()
                                .firstName(request.getFirstname())
                                .lastName(request.getLastname())
                                .educationInstitution(eduInstitution)
                                .dob(request.getDob())
                                .gender(request.getGender())
                                .email(request.getUsernameEmailPhoneNumber())
                                .password(passwordEncoder.encode(request.getPassword()))
                                .accountLocked(false)
                                .enabled(true)
                                .role(userRole)
                                .build();
                        ;
                        otpRepository.deleteByUsernameEmailPhoneNumber(request.getUsernameEmailPhoneNumber());
                        return userRepository.save(user);
                    } else {
                        throw new CodeInvalidException(AppErrorCode.AUTH_INVALID_CODE);
                    }
                })
                .orElseThrow(() -> new AlreadyExistsException(AppErrorCode.USER_EXISTS, "usernameEmailPhoneNumber", request.getUsernameEmailPhoneNumber()));
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


            return AuthenticationResponse.builder()
                    .accessToken(jwtToken)
                    .refreshToken(refreshToken)
                    .educationInstitutionId(info.getEducationInstitution().getId())
                    .educationInstitutionName(info.getEducationInstitution().getName())
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
    public AuthenticationResponse verifyForgotPw(String emailOrUsernameOrPhoneNumber, String otp) {
        String username;
        if (User.isValidEmail(emailOrUsernameOrPhoneNumber)) {
            User user = userRepository.findByEmail(emailOrUsernameOrPhoneNumber).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "emailOrUsernameOrPhoneNumber", emailOrUsernameOrPhoneNumber));
            username = user.getUsername();
        } else if (User.isValidPhoneNumber(emailOrUsernameOrPhoneNumber)) {
            User user = userRepository.findByPhoneNumber(emailOrUsernameOrPhoneNumber).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "emailOrUsernameOrPhoneNumber", emailOrUsernameOrPhoneNumber));
            username = user.getUsername();
        } else
            username = emailOrUsernameOrPhoneNumber;

        Optional<OTP> optionalOTP = otpRepository.findByUsernameEmailPhoneNumber(emailOrUsernameOrPhoneNumber);
        if (optionalOTP.isPresent() &&
                optionalOTP.get().getExpiresAt().isAfter(LocalDateTime.now()) && otp.equals(optionalOTP.get().getOtp())) {
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
