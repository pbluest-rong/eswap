package com.eswap.request;

import jakarta.validation.constraints.NotEmpty;
import lombok.Getter;
import lombok.Setter;

@Getter
@Setter
public class AddCategoryRequest {
    private Long parentCategoryId; // can be null for root categories
    @NotEmpty(message = "Category name is required")
    private String name;
}