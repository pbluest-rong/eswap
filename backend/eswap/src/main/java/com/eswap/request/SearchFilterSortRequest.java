package com.eswap.request;

import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class SearchFilterSortRequest {
    private String keyword;
    private List<Long> categoryIdList;
    private List<Long> brandIdList;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private String condition;
    private String sortBy;
}
