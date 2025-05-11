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
    private String username;
    private String avatarUrl;
    private String role;
    private String firstName;
    private String lastName;
    private long educationInstitutionId;
    private String educationInstitutionName;
    private int unreadNotificationNumber;
    private int unreadMessageNumber;
}