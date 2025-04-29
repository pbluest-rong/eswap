package com.eswap.response;

import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatResponse {
    private long id;
    private long chatPartnerId;
    private String chatPartnerAvatarUrl;
    private String chatPartnerFirstName;
    private String chatPartnerLastName;
    private long educationInstitutionId;
    private String educationInstitutionName;
    private long currentPostId;
    private String currentPostName;
    private BigDecimal currentPostSalePrice;
    private String currentPostFirstMediaUrl;

    private MessageResponse mostRecentMessage;
    private int unReadMessageNumber;
}
