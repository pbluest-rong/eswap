package com.studentswap.features.chat;

import com.studentswap.features.post.Post;
import com.studentswap.features.user.User;
import jakarta.persistence.*;

import java.util.List;

@Entity
@Table(name = "chats")
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

    @OneToOne
    @JoinColumn(name = "current_post_id")
    private Post currentPost;

    @OneToMany(mappedBy = "chat", cascade = CascadeType.ALL)
    private List<Message> messages;
}
