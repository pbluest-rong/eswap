package com.eswap.response;

import com.eswap.common.constants.FollowStatus;
import lombok.Builder;
import lombok.Data;

@Data
@Builder
public class FollowResponse {
    private long id;
    FollowStatus status;
}