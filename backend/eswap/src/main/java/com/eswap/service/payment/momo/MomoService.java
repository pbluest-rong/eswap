package com.eswap.service.payment.momo;

import com.eswap.model.Order;
import com.eswap.service.payment.CreatePaymentRequest;
import com.eswap.service.payment.CreatePaymentResponse;
import com.eswap.service.payment.PaymentService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import javax.crypto.Mac;
import javax.crypto.spec.SecretKeySpec;
import java.math.BigDecimal;
import java.nio.charset.StandardCharsets;
import java.util.UUID;

@Service("momo")
@RequiredArgsConstructor
@Slf4j
public class MomoService implements PaymentService {
    @Value(value = "${momo.partner-code}")
    private String PARTNER_CODE;
    @Value(value = "${momo.access-key}")
    private String ACCESS_KEY;
    @Value(value = "${momo.secret-key}")
    private String SECRET_KEY;
    @Value(value = "${momo.return-url}")
    private String REDIRECT_URL;
    @Value(value = "${momo.ipn-url}")
    private String IPN_URL;
    @Value(value = "${momo.request-type}")
    private String REQUEST_TYPE;

    private final MomoApi momoApi;

    private String signHmacSHA256(String data, String key) throws Exception {
        Mac hmacSha256 = Mac.getInstance("HmacSHA256");
        SecretKeySpec secretKey = new SecretKeySpec(key.getBytes(StandardCharsets.UTF_8), "HmacSHA256");
        hmacSha256.init(secretKey);

        byte[] hash = hmacSha256.doFinal(data.getBytes(StandardCharsets.UTF_8));
        StringBuilder hexString = new StringBuilder();
        for (byte b : hash) {
            String hex = Integer.toHexString(0xff & b);
            if (hex.length() == 1) hexString.append('0');
            hexString.append(hex);
        }
        return hexString.toString();
    }

    public CreatePaymentResponse createPaymentQR(Order order, String extraData) {
        String orderInfo = "Thanh toan don hang: " + order.getId();
        String requestId = UUID.randomUUID().toString();
        String extraDataSafe = extraData == null ? "" : extraData;
        long amount = order.getDepositAmount().longValue();
        String rawSignature = String.format(
                "accessKey=%s&amount=%s&extraData=%s&ipnUrl=%s&orderId=%s&orderInfo=%s&partnerCode=%s&redirectUrl=%s&requestId=%s&requestType=%s",
                ACCESS_KEY, amount, extraDataSafe, IPN_URL, order.getId(), orderInfo, PARTNER_CODE, REDIRECT_URL, requestId, REQUEST_TYPE
        );
        String prettySignature = "";
        try {
            prettySignature = signHmacSHA256(rawSignature, SECRET_KEY);
        } catch (Exception e) {
            log.error("Loi khi hash code: " + e.getMessage());
            return null;
        }
        if (prettySignature.isBlank()) {
            log.error("Loi do signature is blank");
            return null;
        }
        CreatePaymentRequest request = CreatePaymentRequest.builder()
                .partnerCode(PARTNER_CODE)
                .requestType(REQUEST_TYPE)
                .ipnUrl(IPN_URL)
                .redirectUrl(REDIRECT_URL)
                .orderId(order.getId())
                .orderInfo(orderInfo)
                .requestId(requestId)
                .extraData(extraData)
                .amount(order.getDepositAmount().longValue())
                .signature(prettySignature)
                .lang("vi")
                .build();
        return momoApi.createMomoQR(request);
    }

    @Override
    public void refundPayment(String originalTransactionId, BigDecimal amount) {

    }

}
