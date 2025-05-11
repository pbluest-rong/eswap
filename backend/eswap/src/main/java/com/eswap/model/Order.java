package com.eswap.model;

import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;
import org.hibernate.annotations.UpdateTimestamp;

import java.math.BigDecimal;
import java.time.LocalDateTime;

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
    @Column(name = "created_at", updatable = false)
    private LocalDateTime createdAt;

    @UpdateTimestamp
    @Column(name = "updated_at")
    private LocalDateTime updatedAt;

    @Enumerated(EnumType.STRING)
    @Column(name = "cancel_reason")
    private CancelReason cancelReason;
    @Column(name = "cancel_reason_content")
    private String cancelReasonContent;

    public enum CancelReason {
        BUYER_CANCELLED,
        SELLER_REJECTED,
        TIMEOUT,
        OTHER
    }

    public enum OrderStatus {
        PENDING,       // Đơn được tạo nhưng chưa đặt cọc
        SELLER_ACCEPTS, // Người bán cho phép không đặt cọc
        DEPOSITED,     // Đã đặt cọc
        COMPLETED,     // Đã thanh toán đủ
        CANCELLED      // Đã hủy
    }
}