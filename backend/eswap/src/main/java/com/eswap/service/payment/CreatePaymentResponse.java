package com.eswap.service.payment;

import lombok.*;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CreatePaymentResponse {
    private String partnerCode;
    private long responseTime;
    private int resultCode;
    private String payUrl;
    private String deeplink;
    private String qrCodeUrl;
    private String orderId;
    private String requestId;
    private long amount;
    private String message;
}
