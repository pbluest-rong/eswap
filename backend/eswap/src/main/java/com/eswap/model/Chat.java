package com.eswap.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

import java.time.OffsetDateTime;
import java.util.List;

@Entity
@Table(name = "chats")
@Getter
@Setter
public class Chat {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @ManyToOne
    @JoinColumn(name = "user_1_id", nullable = false)
    private User user1;

    @ManyToOne
    @JoinColumn(name = "user_2_id", nullable = false)
    private User user2;

    @ManyToOne
    @JoinColumn(name = "current_post_id")
    private Post currentPost;

    @OneToMany(mappedBy = "chat", cascade = CascadeType.ALL)
    private List<Message> messages;

    @Column(name = "last_message_at")
    private OffsetDateTime lastMessageAt;

}
