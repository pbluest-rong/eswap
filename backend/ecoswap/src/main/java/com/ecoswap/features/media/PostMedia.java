package com.ecoswap.features.media;

import com.ecoswap.common.enums.MediaType;
import com.ecoswap.features.post.Item;
import jakarta.persistence.*;

@Entity
@Table(name = "post_media")
public class PostMedia {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    private String url;

    @Enumerated(EnumType.STRING)
    private MediaType type;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "item_id")
    private Item item;
}
