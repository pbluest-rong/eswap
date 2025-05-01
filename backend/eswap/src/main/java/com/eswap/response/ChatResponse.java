package com.eswap.response;

import com.fasterxml.jackson.annotation.JsonIgnore;
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
