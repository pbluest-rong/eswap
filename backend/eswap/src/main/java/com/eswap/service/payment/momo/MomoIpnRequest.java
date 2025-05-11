package com.eswap.service.payment.momo;

import lombok.Data;

@Data
public class MomoIpnRequest {
    private String partnerCode;
    private String orderId;
    private String requestId;
    private Long amount;
    private String orderInfo;
    private String orderType;
    private Long transId;
    private Integer resultCode;
    private String message;
    private String payType;
    private Long responseTime;
    private String extraData;
    private String signature;
}

    /*
    {
    "partnerCode": "MOMO",
    "orderId": "ORDER-df5ccaa9-02c9-4236-813f-eabe124de401",
    "requestId": "8b9ad266-7b82-498f-8689-c3ab16cfacf5",
    "amount": 720000,
    "orderInfo": "Thanh toan don hang: ORDER-df5ccaa9-02c9-4236-813f-eabe124de401",
    "orderType": "momo_wallet",
    "transId": 3302046017,
    "resultCode": 0,
    "message": "Thành công.",
    "payType": "qr",
    "responseTime": 1746940562747,
    "extraData": "",
    "signature": "6516a83001902bd800165f080cdce29007c295fc7f3878161d014e93a8e0cabc"
    }
     */
