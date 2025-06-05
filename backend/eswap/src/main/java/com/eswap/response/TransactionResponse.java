package com.eswap.response;

import com.eswap.model.Order;
import com.eswap.model.Transaction;
import com.eswap.model.UserBalance;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Getter
@Setter
@Builder
public class TransactionResponse {
    private String id;
    private String orderId;
    private Transaction.TransactionType type;
    private BigDecimal amount;
    private Transaction.TransactionStatus status;
    private OffsetDateTime createdAt;
    private String note;

    public static TransactionResponse mapperToOrderResponse(Transaction transaction) {
        TransactionResponse response = TransactionResponse.builder()
                .id(transaction.getId())
                .type(transaction.getType())
                .amount(transaction.getAmount())
                .status(transaction.getStatus())
                .createdAt(transaction.getCreatedAt())
                .note(transaction.getNote())
                .build();
        Order order = transaction.getOrder();
        if (order != null) {
            response.setOrderId(order.getId());
        }
        return response;
    }
}
