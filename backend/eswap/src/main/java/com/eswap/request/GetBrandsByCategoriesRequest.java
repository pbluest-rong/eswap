package com.eswap.request;

import lombok.Builder;
import lombok.Getter;
import lombok.Setter;

import java.util.List;

@Getter
@Setter
@Builder
public class GetBrandsByCategoriesRequest {
    private List<Long> categoryIdList;
}
