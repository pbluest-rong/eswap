package com.eswap.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.eswap.common.constants.ContentType;
import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;
import org.hibernate.annotations.CreationTimestamp;

import java.time.OffsetDateTime;

@Entity
@Table(name = "messages")
@Getter
@Setter
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @CreationTimestamp
    @Column(name = "created_at", nullable = false, updatable = false)
    private OffsetDateTime createdAt;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "from_user_id")
    private User fromUser;
    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "to_user_id")
    private User toUser;
    @ManyToOne
    @JoinColumn(name = "chat_id")
    @JsonIgnore
    private Chat chat;
    @Column(name = "content_type")
    @Enumerated(EnumType.STRING)
    private ContentType contentType;
    /**
     * ContentType.MEDIA => content = url
     * ContentType.TEXT or LINK => content=text
     * ContentType.POST: content=
     * {
     * "id":id,
     * "name":"name",
     * "salePrice":salePrice
     * }
     * ContentType.LOCATION
     * => {
     * "formatted_address": "Trường Đại học Bách Khoa, 268 Lý Thường Kiệt, Quận 10, Thành phố Hồ Chí Minh, Việt Nam",
     * "place_id": "ChIJ1...",
     * "address_components": [
     * { "long_name": "268", "types": ["street_number"] },
     * { "long_name": "Lý Thường Kiệt", "types": ["route"] },
     * { "long_name": "Phường 14", "types": ["sublocality_level_1"] },
     * { "long_name": "Quận 10", "types": ["administrative_area_level_2"] },
     * { "long_name": "Hồ Chí Minh", "types": ["administrative_area_level_1"] },
     * { "long_name": "Vietnam", "types": ["country"] }
     * ]
     * }
     */
    @Lob
    private String content;
    @Column(name = "is_read")
    private boolean isRead;
}
