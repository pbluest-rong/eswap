package com.studentswap.features.like;

import com.studentswap.features.post.Post;
import com.studentswap.features.user.User;
import jakarta.persistence.*;
import lombok.EqualsAndHashCode;

@Entity
@Table(name = "likes")
public class Like {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    @ManyToOne
    @JoinColumn(name = "post_id")
    @EqualsAndHashCode.Exclude
    private Post post;
    @ManyToOne
    @JoinColumn(name = "user_id")
    @EqualsAndHashCode.Exclude
    private User user;
}
