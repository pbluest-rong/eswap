package com.ecoswap.features.user;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface CodeTokenRepository extends JpaRepository<CodeToken, Integer> {
    Optional<CodeToken> findByToken(String token);

    void deleteByEmail(String email);

    @Query("SELECT ct FROM CodeToken ct WHERE ct.email = :email")
    Optional<CodeToken> findByUserEmail(String email);
}
