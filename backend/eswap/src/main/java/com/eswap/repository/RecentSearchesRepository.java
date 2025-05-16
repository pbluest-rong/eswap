package com.eswap.repository;

import com.eswap.model.RecentSearches;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface RecentSearchesRepository extends JpaRepository<RecentSearches, Long> {
    Optional<RecentSearches> findByUserId(long userId);
}