package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.PageResponse;
import com.eswap.response.OrderCounterResponse;
import com.eswap.response.OrderCreationResponse;
import com.eswap.response.OrderResponse;
import com.eswap.service.OrderService;
import com.eswap.service.payment.CreatePaymentResponse;
import com.eswap.service.payment.momo.MomoIpnRequest;
import lombok.RequiredArgsConstructor;
import org.checkerframework.checker.units.qual.A;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.math.BigDecimal;

@RestController
@RequestMapping("orders")
@RequiredArgsConstructor
public class OrderController {
    private final OrderService orderService;

    @PostMapping
    public ResponseEntity<ApiResponse> createOrder(
            Authentication auth,
            @RequestParam("postId") long postId,
            @RequestParam("quantity") int quantity,
            @RequestParam(value = "paymentType", required = false) String paymentType
    ) {
        OrderCreationResponse order = orderService.createOrder(auth, postId, quantity, paymentType);
        return ResponseEntity.ok(new ApiResponse(true, "Create new order successful", order));
    }

    @GetMapping("/cal-deposit-amount/{amount}")
    public ResponseEntity<ApiResponse> calDepositAmount(@PathVariable("amount") BigDecimal amount) {
        BigDecimal depositAmount = orderService.calDepositAmount(amount);
        return ResponseEntity.ok(new ApiResponse(true, "Create payment QR code successful", depositAmount));
    }

    @PostMapping("/momo/ipn-handler")
    public void ipnHandler(@RequestBody MomoIpnRequest request) {
        if (request.getResultCode() == 0) {
            orderService.handleDepositSuccess(request.getOrderId(), String.valueOf(request.getTransId()));
        }
    }

    // Thanh toán lại
    @PutMapping("/deposit")
    public ResponseEntity<ApiResponse> deposit(Authentication auth, @RequestParam("orderId") String orderId) {
        CreatePaymentResponse paymentResponse = orderService.deposit(auth, orderId);
        return ResponseEntity.ok(new ApiResponse(true, "Create payment successful", paymentResponse));
    }
    // Xóa đơn hàng đang đợi thanh toán
    @DeleteMapping("/delete")
    public ResponseEntity<ApiResponse> deleteOrder(Authentication auth, @RequestParam("orderId") String orderId) {
        OrderResponse order = orderService.deleteOrder(auth, orderId);
        return ResponseEntity.ok(new ApiResponse(true, "Delete order successful", order));
    }

    @PutMapping("/accept-no-deposit")
    public ResponseEntity<ApiResponse> sellerAcceptNoDeposit(Authentication auth, @RequestParam("orderId") String orderId) {
        OrderResponse order = orderService.handleSellerAcceptNoDeposit(auth, orderId);
        return ResponseEntity.ok(new ApiResponse(true, "Seller accepted no deposit for order with id " + orderId, order));
    }

    @PutMapping("/cancel")
    public ResponseEntity<ApiResponse> cancelOrder(Authentication auth, @RequestParam("orderId") String orderId,
                                                   @RequestParam("cancelReasonContent") String cancelReasonContent
    ) {
        OrderResponse order = orderService.cancelOrder(auth, orderId, cancelReasonContent);
        return ResponseEntity.ok(new ApiResponse(true, "Cancel order successful", order));
    }

    @PutMapping("/complete")
    public ResponseEntity<ApiResponse> completeOrder(Authentication auth, @RequestParam("orderId") String orderId) {
        OrderResponse order = orderService.completeOrder(auth, orderId);
        return ResponseEntity.ok(new ApiResponse(true, "Complete order successful", order));
    }

    //đơn mua: chờ xác nhận
    @GetMapping("/buyer/pending")
    public ResponseEntity<ApiResponse> getBuyerPendingOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                             @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getBuyerPendingOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get pending orders successful", orders));
    }

    //đơn mua: đã xác nhận
    @GetMapping("/buyer/seller-accepted")
    public ResponseEntity<ApiResponse> getBuyerAcceptedBySellerOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                                      @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getBuyerAcceptedBySellerOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get accepted orders successful", orders));
    }

    //đơn mua: đợi đặt cọc
    @GetMapping("/buyer/await-deposit")
    public ResponseEntity<ApiResponse> getBuyerAwaitingDepositOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                                     @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getBuyerAwaitingDepositOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get awaiting deposit orders successful", orders));
    }

    //đơn mua: đã đặt cọc
    @GetMapping("/buyer/deposited")
    public ResponseEntity<ApiResponse> getBuyerDepositedOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                               @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getBuyerDepositedOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get deposited orders successful", orders));
    }

    // đơn bán: đã hủy
    @GetMapping("/buyer/cancelled")
    public ResponseEntity<ApiResponse> getBuyerCancelledOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                               @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getBuyerCancelledOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get completed orders successful", orders));
    }

    // đơn bán: đã hoàn thành
    @GetMapping("/buyer/completed")
    public ResponseEntity<ApiResponse> getBuyerCompletedOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                               @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getBuyerCompletedOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get completed orders successful", orders));
    }

    //đơn bán: cần xác nhận
    @GetMapping("/seller/pending")
    public ResponseEntity<ApiResponse> getSellerPendingOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                              @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getSellerPendingOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get pending orders successful", orders));
    }

    // đơn bán: đã xác nhận
    @GetMapping("/seller/accepted")
    public ResponseEntity<ApiResponse> getSellerAcceptedOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                               @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getSellerAcceptedOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get accepted orders successful", orders));
    }

    // đơn bán: đã đặt cọc
    @GetMapping("/seller/deposited")
    public ResponseEntity<ApiResponse> getSellerDepositedOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                                @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getSellerDepositedOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get deposited orders successful", orders));
    }

    // đơn bán: đã hủy
    @GetMapping("/seller/cancelled")
    public ResponseEntity<ApiResponse> getSellerCancelledOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                                @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getSellerCancelledOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get completed orders successful", orders));
    }

    // đơn bán: đã hoàn thành
    @GetMapping("/seller/completed")
    public ResponseEntity<ApiResponse> getSellerCompletedOrders(Authentication auth, @RequestParam(defaultValue = "0") int page,
                                                                @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.getSellerCompletedOrders(auth, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Get completed orders successful", orders));
    }

    @GetMapping("/counter")
    public ResponseEntity<ApiResponse> getOrderCounters(Authentication auth) {
        OrderCounterResponse response = orderService.getOrderCounters(auth);
        return ResponseEntity.ok(new ApiResponse(true, "Get order counters successful", response));
    }

    @GetMapping("/find")
    public ResponseEntity<ApiResponse> findOrders(Authentication auth,
                                                  @RequestParam("keyword") String keyword,
                                                  @RequestParam(defaultValue = "0") int page,
                                                  @RequestParam(defaultValue = "10") int size) {
        PageResponse<OrderResponse> orders = orderService.findOrders(auth, keyword, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "find order successful", orders));
    }
}
