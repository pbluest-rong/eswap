package com.eswap.response;

import com.eswap.model.Order;
import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.time.OffsetDateTime;

@Getter
@Setter
@Builder
public class OrderResponse {
    //post info
    private String id;
    private long postId;
    private String postName;
    private String firstMediaUrl;
    //users info
    private long sellerId;
    private String sellerFirstName;
    private String sellerLastName;
    private long buyerId;
    private String buyerFirstName;
    private String buyerLastName;
    //order info
    private int quantity;
    private BigDecimal totalAmount;
    private BigDecimal depositAmount;
    private BigDecimal remainingAmount;
    private Order.OrderStatus status;
    private OffsetDateTime createdAt;
    private OffsetDateTime updatedAt;
    private Order.CancelReason cancelReason;
    private String cancelReasonContent;

    public static OrderResponse mapperToOrderResponse(Order order) {
        return OrderResponse.builder()
                .id(order.getId())
                .postId(order.getPost().getId())
                .postName(order.getPost().getName())
                .firstMediaUrl(order.getPost().getMedia().get(0).getOriginalUrl())
                .sellerId(order.getSeller().getId())
                .sellerFirstName(order.getSeller().getFirstName())
                .sellerLastName(order.getSeller().getLastName())
                .buyerId(order.getBuyer().getId())
                .buyerFirstName(order.getBuyer().getFirstName())
                .buyerLastName(order.getBuyer().getLastName())
                .quantity(order.getQuantity())
                .totalAmount(order.getTotalAmount())
                .depositAmount(order.getDepositAmount())
                .remainingAmount(order.getRemainingAmount())
                .status(order.getStatus())
                .createdAt(order.getCreatedAt())
                .updatedAt(order.getUpdatedAt())
                .cancelReason(order.getCancelReason())
                .cancelReasonContent(order.getCancelReasonContent())
                .build();
    }
}
