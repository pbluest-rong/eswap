package com.eswap.repository;

import com.eswap.model.UserFcmToken;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FcmTokenRepository extends JpaRepository<UserFcmToken, Long> {
    List<UserFcmToken> findByUserId(Long userId);

    @Query("SELECT u FROM UserFcmToken u WHERE u.userId IN :userIdList")
    List<UserFcmToken> findByUserIdList(@Param("userIdList") List<Long> userIdList);

    void deleteByFcmToken(String fcmToken);

    void deleteByUserId(Long userId);
}
