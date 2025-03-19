package com.eswap.request;

import jakarta.validation.constraints.NotBlank;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class PostMediaRequest {
    @NotBlank
    private String originalUrl;

    @NotBlank
    private String contentType;
}
