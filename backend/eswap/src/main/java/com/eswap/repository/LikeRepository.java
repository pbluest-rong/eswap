package com.eswap.repository;

import com.eswap.model.Like;
import com.eswap.model.Post;
import com.eswap.model.User;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface LikeRepository extends JpaRepository<Like, Long> {
    int countByPostId(Long postId);
    boolean existsByPostIdAndUserId(Long postId, Long userId);

    Optional<Like> findByPostAndUser(Post post, User user);
}
