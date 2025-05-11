package com.eswap.service.payment;

import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class PaymentServiceFactory {
    private final Map<String, PaymentService> services;

    public PaymentServiceFactory(List<PaymentService> serviceList) {
        services = new HashMap<>();
        for (PaymentService service : serviceList) {
            services.put(service.getClass().getAnnotation(Service.class).value(), service);
        }
    }

    public PaymentService getService(String type) {
        return services.get(type); // "momo", "vnpay"
    }
}
