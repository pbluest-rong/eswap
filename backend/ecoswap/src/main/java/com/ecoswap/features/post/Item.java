package com.ecoswap.features.post;

import com.ecoswap.common.enums.ItemStatus;
import com.ecoswap.features.media.PostMedia;
import jakarta.persistence.*;

import java.math.BigDecimal;
import java.util.List;

@Entity
@Table(name = "items")
public class Item {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private String name;
    @Column(name = "original_price", precision = 12, scale = 3)
    private BigDecimal originalPrice;
    @Column(name = "sale_price", precision = 12, scale = 3)
    private BigDecimal salePrice;
    private String description;
    private int quantity;
    private int sold;
    @Enumerated(EnumType.STRING)
    private ItemStatus status;
    @ManyToOne
    @JoinColumn(name = "post_id")
    private Post post;
    @OneToMany(mappedBy = "item")
    private List<PostMedia> media;
}
