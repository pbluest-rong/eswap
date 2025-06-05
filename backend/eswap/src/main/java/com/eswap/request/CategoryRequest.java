package com.eswap.request;

import jakarta.validation.constraints.NotEmpty;

import java.util.Set;

public class CategoryRequest {
    @NotEmpty(message = "Name must not be empty")
    private String name;
    private Long parentId;
    private Set<Long> brandIds;

    // Getters and setters
    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public Long getParentId() {
        return parentId;
    }

    public void setParentId(Long parentId) {
        this.parentId = parentId;
    }

    public Set<Long> getBrandIds() {
        return brandIds;
    }

    public void setBrandIds(Set<Long> brandIds) {
        this.brandIds = brandIds;
    }
}
