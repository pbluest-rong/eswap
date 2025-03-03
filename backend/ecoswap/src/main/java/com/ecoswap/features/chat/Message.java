package com.ecoswap.features.chat;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.ecoswap.common.enums.ContentType;
import com.ecoswap.features.user.User;
import jakarta.persistence.*;
import org.hibernate.annotations.CreationTimestamp;

import java.time.LocalDateTime;

@Entity
@Table(name = "messages")
public class Message {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @CreationTimestamp
    @Column(name = "create_at")
    private LocalDateTime createdAt;
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
    private String content;
}
