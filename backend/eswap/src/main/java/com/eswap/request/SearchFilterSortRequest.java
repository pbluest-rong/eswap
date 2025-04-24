package com.eswap.request;

import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.Getter;
import lombok.Setter;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class SearchFilterSortRequest {
    @Size(min = 3, message = "Keyword phải có ít nhất 3 ký tự")
    @Pattern(regexp = ".*\\S.*", message = "Keyword không được chỉ chứa khoảng trắng")
    private String keyword;
    private List<Long> categoryIdList;
    private List<Long> brandIdList;
    private BigDecimal minPrice;
    private BigDecimal maxPrice;
    private String condition;
    private String sortBy;
}
