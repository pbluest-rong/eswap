package com.eswap.service.payment.momo;

import com.eswap.service.payment.CreatePaymentRequest;
import com.eswap.service.payment.CreatePaymentResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "momo", url = "${momo.end-point}")
public interface MomoApi {
    @PostMapping("/create")
    CreatePaymentResponse createMomoQR(@RequestBody CreatePaymentRequest createMomoRequest);
}
