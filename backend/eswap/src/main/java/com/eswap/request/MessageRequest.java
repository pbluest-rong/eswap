package com.eswap.request;

import com.eswap.common.constants.ContentType;
import lombok.Getter;

@Getter
public class MessageRequest {
    long chatPartnerId;
    ContentType contentType;
    String content;
    long postId;
}
