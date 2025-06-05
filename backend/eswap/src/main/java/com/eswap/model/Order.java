package com.eswap.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Entity
@Table(name = "orders")
@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class Order {

    @Id
    private String id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "post_id", nullable = false)
    private Post post;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "buyer_id", nullable = false)
    private User buyer;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "seller_id", nullable = false)
    private User seller;

    @Column(nullable = false)
    private Integer quantity;

    @Column(name = "total_amount", nullable = false, precision = 19, scale = 2)
    private BigDecimal totalAmount;

    @Column(name = "deposit_amount", nullable = false, precision = 19, scale = 2)
    private BigDecimal depositAmount;

    @Column(name = "remaining_amount", nullable = false, precision = 19, scale = 2)
    private BigDecimal remainingAmount;

    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private OrderStatus status;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @Column(name = "updated_at")
    private OffsetDateTime updatedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "cancel_reason")
    private CancelReason cancelReason;
    @Column(name = "cancel_reason_content")
    private String cancelReasonContent;
    @Column(name = "number_deposit_payments")
    private int numberDepositPayments;
    @Column(name = "payment_transaction_id")
    private String paymentTransactionId;

    public enum CancelReason {
        BUYER_CANCELLED,
        SELLER_REJECTED,
        TIMEOUT,
        OTHER
    }

    public enum OrderStatus {
        PENDING,       // Đơn được tạo nhưng chưa đặt cọc
        SELLER_ACCEPTS, // Người bán cho phép không đặt cọc
        AWAITING_DEPOSIT,
        DEPOSITED,     // Đã đặt cọc
        COMPLETED,     // Đã thanh toán đủ
        CANCELLED, // Đã hủy
        DELETED
    }
}