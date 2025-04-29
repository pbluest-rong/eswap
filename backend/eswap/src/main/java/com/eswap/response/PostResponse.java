package com.eswap.response;

import com.eswap.common.constants.*;
import com.eswap.model.*;
import jakarta.persistence.*;
import lombok.*;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.OffsetDateTime;
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
    private FollowStatus followStatus;

    //post
    private long id;
    private long educationInstitutionId;
    private String educationInstitutionName;

    private String name;
    private String description;
    private String brand;
    private BigDecimal originalPrice;
    private BigDecimal salePrice;
    private int quantity;
    private int sold;
    private PostStatus status;
    private Privacy privacy;
    private OffsetDateTime availableTime;
    private Condition condition;
    private OffsetDateTime createdAt;
    private List<PostMedia> media;
    private int likesCount;
    private boolean liked;

    public static PostResponse mapperToResponse(Post post, String firstname, String lastname, String avtUrl,
                                                int likesCount, boolean liked, FollowStatus followStatus) {
        return PostResponse.builder()
                .userId(post.getUser().getId())
                .firstname(firstname)
                .lastname(lastname)
                .avtUrl(avtUrl)
                .id(post.getId())
                .educationInstitutionId(post.getEducationInstitution().getId())
                .educationInstitutionName(post.getEducationInstitution().getName())
                .name(post.getName())
                .description(post.getDescription())
                .brand(post.getBrand() != null ? post.getBrand().getName() : null)
                .originalPrice(post.getOriginalPrice())
                .salePrice(post.getSalePrice())
                .quantity(post.getQuantity())
                .sold(post.getSold())
                .status(post.getStatus())
                .privacy(post.getPrivacy())
                .availableTime(post.getAvailableTime().calculateExpirationTime(post.getCreatedAt()))
                .condition(post.getCondition())
                .createdAt(post.getCreatedAt())
                .media(post.getMedia())
                .likesCount(likesCount)
                .liked(liked)
                .followStatus(followStatus)
                .build();
    }

    @Override
    public String toString() {
        return "PostResponse{" +
                "id=" + id +
                ", name='" + name + '\'' +
                ", description='" + description + '\'' +
                ", brand=" + brand +
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
