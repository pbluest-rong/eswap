package com.eswap.request;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AddBrandRequest {
    @NotNull(message = "Category ID is required")
    private Long categoryId;
    @NotEmpty(message = "Brand name is required")
    private String name;
}