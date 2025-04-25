package com.eswap.request;

import com.eswap.common.constants.AvailableTime;
import com.eswap.common.constants.Condition;
import com.eswap.common.constants.PostStatus;
import com.eswap.common.constants.Privacy;
import lombok.Getter;
import lombok.Setter;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
import java.util.List;

@Getter
@Setter
public class AddPostRequest {
    private String name;
    private String description;
    private Long categoryId;
    private Long brandId;
    private BigDecimal originalPrice;
    private BigDecimal salePrice;
    private int quantity;
    private Privacy privacy;
    private Condition condition;
    private String address;
    private String phoneNumber;
}
/**
 * Danh mục
 * privacy: follower, public
 * images: 0 < img <=5
 * video: <=1 (tùy chọn)
 * condition
 * name
 * description
 * brand (tùy chọn)
 * origin (tùy chọn)
 * originalPrice (tùy chọn)
 * salePrice
 * quantity
 * address (tùy chọn)
 * phoneNumber (tùy chọn)
 * medias
 */
