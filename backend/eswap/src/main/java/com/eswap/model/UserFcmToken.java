package com.eswap.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Table(name = "user_fcm_token", uniqueConstraints = {
        @UniqueConstraint(columnNames = {"fcmToken"})
})
@Getter
@Setter
public class UserFcmToken {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id;
    private Long userId;
    @Column(nullable = false, unique = true)
    private String fcmToken;
}
