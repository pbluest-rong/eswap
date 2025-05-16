package com.eswap.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class OrderCounterResponse {
    private int buyerPendingOrderNumber;
    private int buyerAcceptedOrderNumber;
    private int buyerAwaitingDepositNumber;
    private int buyerDepositedOrderNumber;
    private int buyerCancelledOrderNumber;
    private int buyerCompletedOrderNumber;

    private int sellerPendingOrderNumber;
    private int sellerAcceptedOrderNumber;
    private int sellerDepositedOrderNumber;
    private int sellerCancelledOrderNumber;
    private int sellerCompletedOrderNumber;
}