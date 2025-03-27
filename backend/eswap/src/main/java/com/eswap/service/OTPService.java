package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.exception.OtpLimitExceededException;
import com.eswap.model.OTP;
import com.eswap.repository.OTPRepository;
import com.eswap.response.OTPResponse;
import jakarta.mail.MessagingException;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class OTPService {
    private final OTPRepository tokenRepository;
    private final EmailService emailService;
    private final int REQUEST_COUNT_MAX = 5;

    public OTPResponse sendCodeToken(String email, long minutes) {
        OTP otp = tokenRepository.findByUserEmail(email).orElse(null);
        String generatedToken = generateActivationCode(6);
        if (otp != null) {
            if (otp.getRequestCount() >= REQUEST_COUNT_MAX) {
                if (!otp.getCreatedAt().toLocalDate().equals(LocalDate.now()))
                    otp.setRequestCount(0);
                else
                    throw new OtpLimitExceededException(AppErrorCode.OTP_LIMIT_EXCEEDED, REQUEST_COUNT_MAX);
            }
            otp.setOtp(generatedToken);
            otp.setCreatedAt(LocalDateTime.now());
            otp.setExpiresAt(LocalDateTime.now().plusMinutes(minutes));
            otp.setRequestCount(otp.getRequestCount() + 1);
        } else {
            otp = OTP.builder()
                    .otp(generatedToken)
                    .createdAt(LocalDateTime.now())
                    .expiresAt(LocalDateTime.now().plusMinutes(minutes))
                    .email(email)
                    .requestCount(1)
                    .build();
        }
        tokenRepository.save(otp);
        String htmlContent = emailService.buildVerificationEmail(otp.getOtp(), minutes);
        try {
            emailService.sendMail(email, "Xác thực Email!", htmlContent, minutes);
        } catch (MessagingException e) {
            throw new RuntimeException(e);
        }
        return new OTPResponse(minutes);
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
}
