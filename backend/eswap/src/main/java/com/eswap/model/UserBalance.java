package com.eswap.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "user_balance")
@Getter
@Setter
public class UserBalance {
    @Id
    private Long userId;
    @Column(nullable = false)
    private BigDecimal balance = BigDecimal.ZERO;
    private String bankName;
    private String bankAccountNumber;
    private String accountHolder;
    private boolean isWithdrawRequested;
    private OffsetDateTime withdrawDateTime;
}
