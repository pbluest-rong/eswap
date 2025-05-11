package com.eswap.repository;

import com.eswap.model.Notification;
import com.eswap.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificationRepository extends JpaRepository<Notification, Long> {
    @Query("""
            SELECT n FROM Notification n
                        WHERE n.recipientId =:userId
                                OR n.recipientType=com.eswap.common.constants.RecipientType.ALL_USERS
                                 OR (
                                    n.recipientType = com.eswap.common.constants.RecipientType.FOLLOWERS
                                   AND EXISTS (
                                     SELECT 1 FROM Follow f
                                     WHERE f.followee.id = n.senderId
                                     AND f.follower.id = :userId
                                     AND f.waitConfirm=false
                                     AND f.createdAt <= n.createdAt
                                   )
                                )
            ORDER BY n.createdAt DESC
            """)
    Page<Notification> getNotifications(@Param("userId") long userId, Pageable pageable);

    @Query("SELECT COUNT(n) FROM Notification n WHERE n.recipientId = :userId AND n.isRead = false")
    int countUnreadByRecipientId(@Param("userId") long userId);

}
