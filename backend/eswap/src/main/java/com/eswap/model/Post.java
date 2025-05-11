package com.eswap.model;

import com.eswap.common.constants.AvailableTime;
import com.eswap.common.constants.Condition;
import com.eswap.common.constants.PostStatus;
import com.eswap.common.constants.Privacy;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.math.BigDecimal;
import java.sql.Timestamp;
import java.time.OffsetDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "posts")
@Getter
@Setter
public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    private String name;
    private String description;

    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;

    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;

    @ManyToOne
    @JoinColumn(name = "brand_id")
    private Brand brand;

    @ManyToOne
    @JoinColumn(name = "education_institution_id")
    private EducationInstitution educationInstitution;

    @Column(name = "original_price", precision = 12, scale = 3)
    private BigDecimal originalPrice;

    @Column(name = "sale_price", precision = 12, scale = 3)
    private BigDecimal salePrice;

    private int quantity;

    private int sold;// sold == quantity => hết hàng

    @Enumerated(EnumType.STRING)
    private PostStatus status;

    @Enumerated(EnumType.STRING)
    private Privacy privacy;

    @Enumerated(EnumType.STRING)
    @Column(name = "available_time")
    private AvailableTime availableTime;

    @Enumerated(EnumType.STRING)
    @Column(name = "item_condition ")
    private Condition condition;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @OneToMany(mappedBy = "post", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<PostMedia> media = new ArrayList<>();

    private String address;

    private String phoneNumber;
}
