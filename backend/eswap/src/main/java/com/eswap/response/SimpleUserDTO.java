package com.eswap.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class SimpleUserDTO {
    private long id;
    private String username;
    private String firstname;
    private String lastname;
    private String avatarUrl;
}
