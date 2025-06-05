package com.eswap.repository;

import com.eswap.model.User;
import com.eswap.model.Follow;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface FollowRepository extends JpaRepository<Follow, Long> {
    @Query("SELECT f FROM Follow f WHERE f.follower.id = :followerId AND f.followee.id = :followeeId")
    Follow getByFollowerIdAndFolloweeId(@Param("followerId") long followerId, @Param("followeeId") long followeeId);

    Optional<Follow> findByFollowerAndFollowee(User user, User followeeUser);

    @Query("SELECT f.follower FROM Follow f WHERE f.followee.id = :userId AND f.waitConfirm=false ")
    List<User> findFollowersByUserId(@Param("userId") long userId);


    @Query("""
             SELECT COUNT(f) FROM Follow f
                WHERE f.waitConfirm = false
                            AND f.followee = :user
            """)
    int countFollower(User user);

    @Query("""
             SELECT COUNT(f) FROM Follow f
                WHERE f.waitConfirm = false
                            AND f.follower = :user
            """)
    int countFollowee(User user);
}
