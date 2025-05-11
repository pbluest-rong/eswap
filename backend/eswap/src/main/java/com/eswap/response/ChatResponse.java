package com.eswap.response;

import com.eswap.common.constants.DealAgreementStatus;
import com.fasterxml.jackson.annotation.JsonIgnore;
import lombok.*;

import java.math.BigDecimal;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class ChatResponse {
    // Chat
    private long id;
    private long chatPartnerId;
    private String chatPartnerAvatarUrl;
    private String chatPartnerFirstName;
    private String chatPartnerLastName;
    private long educationInstitutionId;
    private String educationInstitutionName;
    //Current Post
    private long currentPostId;
    private long currentPostUserId;
    private String currentPostName;
    private BigDecimal currentPostSalePrice;
    private String currentPostFirstMediaUrl;
    private int quantity;
    private int sold;

    // Messages
    private MessageResponse mostRecentMessage;
    private int unReadMessageNumber;
    private boolean forMe;

    @Override
    public String toString() {
        return "ChatResponse{" +
                "id=" + id +
                ", chatPartnerId=" + chatPartnerId +
                ", chatPartnerAvatarUrl='" + chatPartnerAvatarUrl + '\'' +
                ", chatPartnerFirstName='" + chatPartnerFirstName + '\'' +
                ", chatPartnerLastName='" + chatPartnerLastName + '\'' +
                ", educationInstitutionId=" + educationInstitutionId +
                ", educationInstitutionName='" + educationInstitutionName + '\'' +
                ", currentPostId=" + currentPostId +
                ", currentPostName='" + currentPostName + '\'' +
                ", currentPostSalePrice=" + currentPostSalePrice +
                ", currentPostFirstMediaUrl='" + currentPostFirstMediaUrl + '\'' +
                ", mostRecentMessage=" + mostRecentMessage +
                ", unReadMessageNumber=" + unReadMessageNumber +
                ", isForMe=" + forMe +
                '}';
    }
}
