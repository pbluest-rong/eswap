package com.eswap.response;

import com.eswap.model.UserBalance;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Getter
@Setter
@Builder
public class UserBalanceResponse {
    private long userId;
    private String bankName;
    private String bankAccountNumber;
    private String accountHolder;
    private BigDecimal balance;
    private boolean isWithdrawRequested;
    private OffsetDateTime withdrawDateTime;

    public static UserBalanceResponse mapperToOrderResponse(UserBalance userBalance) {
        return UserBalanceResponse.builder()
                .userId(userBalance.getUserId())
                .bankName(userBalance.getBankName())
                .bankAccountNumber(userBalance.getBankAccountNumber())
                .accountHolder(userBalance.getAccountHolder())
                .balance(userBalance.getBalance())
                .isWithdrawRequested(userBalance.isWithdrawRequested())
                .withdrawDateTime(userBalance.getWithdrawDateTime())
                .build();
    }
}
