package com.eswap.service.payment;

import com.eswap.model.Order;

import java.math.BigDecimal;

public interface PaymentService {
    CreatePaymentResponse createPaymentQR(Order order, String extraData);

    void refundPayment(String momoTransactionId, BigDecimal depositAmount);
}
