package com.eswap.service.payment;

import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequiredArgsConstructor
@RequestMapping("payment")
public class PaymentController {
    private final PaymentServiceFactory paymentServiceFactory;

//    @PostMapping("/{type}")
//    public ResponseEntity<?> createPayment(@PathVariable String type, @RequestBody CreatePaymentRequest request) {
//        PaymentService service = paymentServiceFactory.getService(type);
//        if (service == null) {
//            return ResponseEntity.badRequest().body("Loại thanh toán không hỗ trợ: " + type);
//        }
//        return ResponseEntity.ok(service.createPaymentQR(request));
//    }
}
