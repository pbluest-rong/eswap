package com.eswap.model;

import jakarta.persistence.*;
import lombok.Getter;
import lombok.Setter;

@Entity
@Getter
@Setter
@Table(uniqueConstraints = {
        @UniqueConstraint(columnNames = {"userId"})
})
public class RecentSearches {
    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id;
    @Column(nullable = false)
    private long userId;
    @Column(length = 100)
    private String word1;
    @Column(length = 100)
    private String word2;
    @Column(length = 100)
    private String word3;
    @Column(length = 100)
    private String word4;
    @Column(length = 100)
    private String word5;
}
