package com.eswap.response;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
@Builder
public class AuthenticationResponse {
    private String accessToken;
    private String refreshToken;
    private long userId;
    private String role;
    private long educationInstitutionId;
    private String educationInstitutionName;
}