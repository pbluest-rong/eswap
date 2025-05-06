package com.eswap.response;

import com.eswap.common.constants.DealAgreementStatus;
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.databind.SerializationFeature;
import com.fasterxml.jackson.datatype.jsr310.JavaTimeModule;
import com.google.gson.Gson;
import lombok.*;

import java.math.BigDecimal;
import java.time.OffsetDateTime;
import java.util.Map;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class DealAgreementResponse {
    private long id;
    private long postId;
    private String firstMediaUrl;
    private String postName;
    private BigDecimal originalPrice;
    private BigDecimal salePrice;
    private int quantity;
    private String sellerFirstName;
    private String sellerLastName;
    private String buyerFirstName;
    private String buyerLastName;
    private OffsetDateTime requestAt;
    private OffsetDateTime completedAt;
    private DealAgreementStatus status;

    public String convertJson() {
        try {
            ObjectMapper objectMapper = new ObjectMapper();
            objectMapper.registerModule(new JavaTimeModule());
            objectMapper.disable(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS);
            return objectMapper.writeValueAsString(this);
        } catch (JsonProcessingException e) {
            e.printStackTrace();
        }
        return null;
    }

}
