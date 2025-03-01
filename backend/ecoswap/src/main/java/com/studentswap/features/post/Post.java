package com.studentswap.features.post;

import com.studentswap.common.enums.AvailableTime;
import com.studentswap.features.education_institution.EducationInstitution;
import com.studentswap.features.category.Brand;
import com.studentswap.features.category.Category;
import com.studentswap.features.user.User;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.sql.Timestamp;
import java.util.List;

@Entity
@Table(name = "posts")
public class Post {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private String title;
    @ManyToOne
    @JoinColumn(name = "education_institution_id")
    private EducationInstitution educationInstitution;
    @CreationTimestamp
    @Column(name = "created_at")
    private Timestamp createdAt;
    @Enumerated(EnumType.STRING)
    @Column(name = "available_time")
    private AvailableTime availableTime;
    @ManyToOne
    @JoinColumn(name = "category_id")
    private Category category;
    @ManyToOne
    @JoinColumn(name = "brand_id")
    private Brand brand;
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    @Column(name = "is_deleted")
    private boolean isDeleted;
    @OneToMany(mappedBy = "post")
    private List<Item> items;
}
