package com.eswap.repository;

import com.eswap.model.User;
import com.eswap.model.Follow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface FollowRepository extends JpaRepository<Follow, Long> {
    boolean existsByFollowerAndFollowee(User user, User followeeUser);

    Optional<Follow> findByFollowerAndFollowee(User user, User followeeUser);
}
