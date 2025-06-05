package com.eswap.request;

import jakarta.validation.constraints.NotEmpty;

import java.util.Set;

public class BrandRequest {
    @NotEmpty(message = "Name must not be empty")
    private String name;
    private Set<Long> categoryIds;

    // Getters and setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Set<Long> getCategoryIds() {
        return categoryIds;
    }

    public void setCategoryIds(Set<Long> categoryIds) {
        this.categoryIds = categoryIds;
    }
}