package com.eswap.repository;

import com.eswap.model.OTP;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface OTPRepository extends JpaRepository<OTP, Integer> {
    Optional<OTP> findByOtp(String otp);

    void deleteByEmail(String email);

    @Query("SELECT ct FROM OTP ct WHERE ct.email = :email")
    Optional<OTP> findByUserEmail(String email);
}
