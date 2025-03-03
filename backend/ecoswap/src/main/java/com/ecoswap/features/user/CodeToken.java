package com.ecoswap.features.user;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Getter
@Setter
@Builder
@AllArgsConstructor
@NoArgsConstructor
@Entity()
@Table(name = "code_token", uniqueConstraints = {@UniqueConstraint(columnNames = "email")})
public class CodeToken {
    @Id
    @GeneratedValue
    private Integer id;
    private String token;
    private LocalDateTime createdAt;
    private LocalDateTime expiresAt;
    private LocalDateTime validatedAt;
    private String email;
}
