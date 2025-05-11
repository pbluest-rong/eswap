package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.model.Order;
import com.eswap.service.OrderService;
import com.eswap.service.payment.CreatePaymentResponse;
import com.eswap.service.payment.momo.MomoIpnRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;

    @PostMapping
    public ResponseEntity<ApiResponse> createOrder(
            Authentication auth,
            @RequestParam("postId") long postId,
            @RequestParam("quantity") int quantity) {
        Order order = orderService.createOrder(auth, postId, quantity);
        return ResponseEntity.ok(new ApiResponse(true, "Create new order successful", null));
    }

    @PostMapping("/deposit")
    public ResponseEntity<ApiResponse> buyerDeposit(Authentication auth, @RequestParam("orderId") String orderId, @RequestParam("paymentType") String paymentType) {
        CreatePaymentResponse createPaymentResponse = orderService.processDeposit(auth, orderId, paymentType);
        return ResponseEntity.ok(new ApiResponse(true, "Create payment QR code successful", createPaymentResponse));
    }

    @PutMapping("/accept-no-deposit")
    public ResponseEntity<ApiResponse> sellerAcceptNoDeposit(Authentication auth, @RequestParam("orderId") String orderId) {
        orderService.handleSellerAcceptNoDeposit(auth, orderId);
        return ResponseEntity.ok(new ApiResponse(true, "Seller accepted no deposit for order with id " + orderId, null));
    }

    @PutMapping("/cancel")
    public ResponseEntity<ApiResponse> cancelOrder(Authentication auth, @RequestParam("orderId") String orderId,
                                                   @RequestParam("cancelReasonContent") String cancelReasonContent
    ) {
        orderService.cancelOrder(auth, orderId, cancelReasonContent);
        return ResponseEntity.ok(new ApiResponse(true, "Cancel order successful", null));
    }

    @PutMapping("/complete")
    public ResponseEntity<ApiResponse> completeOrder(Authentication auth, @RequestParam("orderId") String orderId) {
        orderService.completeOrder(auth, orderId);
        return ResponseEntity.ok(new ApiResponse(true, "Complete order successful", null));
    }

    @PostMapping("/momo/ipn-handler")
    public String ipnHandler(@RequestBody MomoIpnRequest request) {
        System.out.println("ipn-handler: " + request.getMessage());
        if (request.getResultCode() == 0) {
            orderService.handleDepositSuccess(request.getOrderId(), String.valueOf(request.getTransId()));
            return "Giao dich thanh cong";
        }
        return "Giao dich that bai";
    }
}
