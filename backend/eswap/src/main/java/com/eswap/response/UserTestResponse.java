package com.eswap.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class UserTestResponse {
    private String username;
    private String email;
}
