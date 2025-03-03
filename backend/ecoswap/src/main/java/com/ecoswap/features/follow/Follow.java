package com.ecoswap.features.follow;

import com.ecoswap.features.user.User;
import jakarta.persistence.*;
import lombok.Data;

@Entity
@Table(name = "follows")
@Data
public class Follow {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;

    @ManyToOne
    @JoinColumn(name = "follower_id", nullable = false)
    private User follower;

    @ManyToOne
    @JoinColumn(name = "followee_id", nullable = false)
    private User followee;
}
