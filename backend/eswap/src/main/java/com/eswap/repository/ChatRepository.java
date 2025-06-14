package com.eswap.repository;

import com.eswap.model.Chat;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Modifying;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import java.util.Optional;

@Repository
public interface ChatRepository extends JpaRepository<Chat, Long> {
    @Query("""
                SELECT c FROM Chat c
                WHERE (c.user1.id = :user1Id OR c.user2.id = :user1Id)
                            ORDER BY c.lastMessageAt DESC
            """)
    Page<Chat> getChats(@Param("user1Id") long user1Id, Pageable pageable);

    @Query("""
                    SELECT c FROM Chat c
                    WHERE (c.user1.id = :userId OR c.user2.id = :userId)
                    AND (c.currentPost.name like %:keyword% 
                         OR (CASE WHEN c.user1.id = :userId THEN 
                              (c.user2.firstName like %:keyword% OR c.user2.lastName like %:keyword%)
                             ELSE 
                              (c.user1.firstName like %:keyword% OR c.user1.lastName like %:keyword%)
                             END))
                    ORDER BY c.lastMessageAt DESC
            """)
    Page<Chat> getChats(@Param("userId") long userId, @Param("keyword") String keyword, Pageable pageable);


    @Query("""
                SELECT c FROM Chat c
                WHERE (c.user1.id = :user1Id AND c.user2.id = :user2Id)
                   OR (c.user1.id = :user2Id AND c.user2.id = :user1Id)
            """)
    Chat findChatBetweenUsers(@Param("user1Id") long user1Id, @Param("user2Id") long user2Id);

    @Modifying
    @Transactional
    @Query("""
            UPDATE Message m
            SET m.isRead = true 
            WHERE m.toUser.id =:userId
                    AND m.fromUser.id = :chatPartnerId
            """)
    void markAsRead(long userId, Long chatPartnerId);
}
