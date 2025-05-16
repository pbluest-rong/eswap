package com.eswap.response;

import com.eswap.service.payment.CreatePaymentResponse;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class OrderCreationResponse {
    private OrderResponse order;
    private CreatePaymentResponse payment;
}