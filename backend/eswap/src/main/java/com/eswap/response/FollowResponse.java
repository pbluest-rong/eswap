package com.eswap.response;

import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FollowResponse {
    private long id;
    private SimpleUserDTO follower;
    private SimpleUserDTO followee;
}