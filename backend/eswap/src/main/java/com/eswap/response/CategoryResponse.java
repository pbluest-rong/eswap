package com.eswap.response;

import com.eswap.common.constants.Condition;
import com.eswap.common.constants.PostStatus;
import com.eswap.common.constants.Privacy;
import com.eswap.model.Brand;
import com.eswap.model.Category;
import com.eswap.model.Post;
import com.eswap.model.PostMedia;
import lombok.*;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;
import java.util.Set;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
public class CategoryResponse {
    private long id;
    private String name;
    private List<CategoryResponse> children;
    private Set<Brand> brands;
}
