package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.exception.*;
import com.eswap.common.security.JwtService;
import com.eswap.model.EducationInstitution;
import com.eswap.repository.EducationInstitutionRepository;
import com.eswap.request.AuthenticationRequest;
import com.eswap.request.ForgotPasswordRequest;
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
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;
import java.util.HashMap;
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
                    Optional<OTP> optionalToken = otpRepository.findByUserEmail(request.getEmail());
                    if (optionalToken.isPresent() &&
                            optionalToken.get().getExpiresAt().isAfter(LocalDateTime.now()) &&
                            optionalToken.get().getValidatedAt() == null && request.getOtp().equals(optionalToken.get().getOtp())) {

                        EducationInstitution eduInstitution = educationInstitutionRepository.findById(request.getEducationInstitutionId()).orElseThrow(() -> new IllegalArgumentException("EDUCATION INSTITUTION ID was not initialized"));
                        User user = User.builder()
                                .firstName(request.getFirstname())
                                .lastName(request.getLastname())
                                .educationInstitution(eduInstitution)
                                .dob(request.getDob())
                                .gender(request.getGender())
                                .email(request.getEmail())
                                .password(passwordEncoder.encode(request.getPassword()))
                                .accountLocked(false)
                                .enabled(true)
                                .role(userRole)
                                .build();
                        ;
                        otpRepository.deleteByEmail(request.getEmail());
                        return userRepository.save(user);
                    } else {
                        throw new CodeInvalidException(AppErrorCode.AUTH_INVALID_CODE);
                    }
                })
                .orElseThrow(() -> new AlreadyExistsException(AppErrorCode.USER_EXISTS, "email", request.getEmail()));
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
            throw new InvalidCredentialsException(AppErrorCode.USER_INVALID_CREDENTIALS);
        } catch (LockedException ex) {
            throw new AccountLockedException(AppErrorCode.USER_LOCKED);
        }
    }

    /**
     * 4 verify forgot password
     */
    public boolean verifyForgotPw(String email, String otp) {
        User user = userRepository.findByEmail(email).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "email", email));
        Optional<OTP> optionalOTP = otpRepository.findByUserEmail(email);
        if (optionalOTP.isPresent() &&
                optionalOTP.get().getExpiresAt().isAfter(LocalDateTime.now()) &&
                optionalOTP.get().getValidatedAt() == null && otp.equals(optionalOTP.get().getOtp())) {
            OTP codeToken = optionalOTP.get();
            if (codeToken.getIncreaseTimeCount() > 0) {
                codeToken.setExpiresAt(LocalDateTime.now().plusMinutes(10));
                codeToken.setIncreaseTimeCount(codeToken.getIncreaseTimeCount() - 1);
                otpRepository.save(codeToken);
            }
            return true;
        } else {
            throw new CodeInvalidException(AppErrorCode.AUTH_INVALID_CODE);
        }
    }

    /**
     * 5 forgor password
     */
    public void forgotPassword(ForgotPasswordRequest request) {
        User user = userRepository.findByEmail(request.getEmail()).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "email", request.getEmail()));
        Optional<OTP> optionalToken = otpRepository.findByUserEmail(request.getEmail());
        if (optionalToken.isPresent() &&
                optionalToken.get().getExpiresAt().isAfter(LocalDateTime.now()) &&
                optionalToken.get().getValidatedAt() == null && request.getOtp().equals(optionalToken.get().getOtp())) {
            user.setPassword(passwordEncoder.encode(request.getNewPassword()));
            userRepository.save(user);
        } else {
            throw new CodeInvalidException(AppErrorCode.AUTH_INVALID_CODE);
        }
    }

    public boolean checkExistEmail(@Email(message = "Email is not formatted") @NotEmpty(message = "Email is mandatory") String email) {
       return  userRepository.existsByEmail(email);
    }
}
