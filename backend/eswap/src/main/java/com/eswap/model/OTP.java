package com.eswap.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity()
@Table(name = "otp", uniqueConstraints = {@UniqueConstraint(columnNames = "usernameEmailPhoneNumber")})
public class OTP {
    @Id
    @GeneratedValue
    private Integer id;
    private String otp;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private String usernameEmailPhoneNumber;
    private int requestCount = 0;
}
