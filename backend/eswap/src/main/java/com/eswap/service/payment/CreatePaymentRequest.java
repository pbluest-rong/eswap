package com.eswap.service.payment;

import lombok.*;

@Builder
@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CreatePaymentRequest {
    private String partnerCode;
    private String requestType;
    private String ipnUrl;
    private String redirectUrl;
    private String lang;
    private String signature;
    private String orderId;
    private long amount;
    private String orderInfo;
    private String requestId;
    private String extraData;
}
