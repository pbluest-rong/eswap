package com.eswap.response;

import com.eswap.common.constants.AvailableTime;
import com.eswap.common.constants.PostStatus;
import com.eswap.common.constants.Privacy;
import com.eswap.model.*;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.util.List;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class PostResponse {
    //user info
    private long userId;
    private String firstname;
    private String lastname;
    private String avtUrl;

    //post
    private long id;
    private EducationInstitution educationInstitution;
    private String name;
    private String description;
    private Brand brand;
    private BigDecimal originalPrice;
    private BigDecimal salePrice;
    private int quantity;
    private int sold;
    private PostStatus status;
    private Privacy privacy;
    private AvailableTime availableTime;
    private Timestamp createdAt;
    private List<PostMedia> media;
    private int likesNumber;

    public static PostResponse mapperToResponse(Post post, String firstname, String lastname, String avtUrl, int likesNumber) {
        return PostResponse.builder()
                .userId(post.getUser().getId())
                .firstname(firstname)
                .lastname(lastname)
                .avtUrl(avtUrl)
                .id(post.getId())
                .educationInstitution(post.getEducationInstitution())
                .name(post.getName())
                .description(post.getDescription())
                .brand(post.getBrand())
                .originalPrice(post.getOriginalPrice())
                .salePrice(post.getSalePrice())
                .quantity(post.getQuantity())
                .sold(post.getSold())
                .status(post.getStatus())
                .privacy(post.getPrivacy())
                .availableTime(post.getAvailableTime())
                .createdAt(post.getCreatedAt())
                .media(post.getMedia())
                .likesNumber(likesNumber)
                .build();
    }

    @Override
    public String toString() {
        return "PostResponse{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", brand=" + brand +
                ", educationInstitution=" + educationInstitution +
                ", originalPrice=" + originalPrice +
                ", salePrice=" + salePrice +
                ", quantity=" + quantity +
                ", sold=" + sold +
                ", status=" + status +
                ", privacy=" + privacy +
                ", availableTime=" + availableTime +
                ", createdAt=" + createdAt +
                ", media=" + media +
                ", userId=" + userId +
                '}';
    }
}
