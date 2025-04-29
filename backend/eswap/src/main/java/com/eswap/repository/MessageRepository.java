package com.eswap.repository;

import com.eswap.model.Chat;
import com.eswap.model.Message;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MessageRepository extends JpaRepository<Message, Long> {
    @Query("""
            SELECT m FROM Message m
            WHERE (m.fromUser.id=:user1Id AND m.toUser.id=:user2Id)
                OR (m.fromUser.id=:user2Id AND m.toUser.id=:user1Id)
            ORDER BY m.createdAt DESC
            """)
    Page<Message> getMessage(long user1Id, long user2Id, Pageable pageable);

    Message findTopByChatOrderByCreatedAtDesc(Chat chat);


    @Query("""
                SELECT COUNT(m) FROM Message m
                WHERE m.toUser.id = :receiverId
                  AND m.isRead = false
            """)
    int countUnreadMessagesForUser(@Param("receiverId") long receiverId);


    @Query("""
                SELECT COUNT(m) FROM Message m
                WHERE m.toUser.id = :receiverId
                  AND m.fromUser.id = :senderId
                  AND m.isRead = false
            """)
    int countUnreadMessagesFromSender(
            @Param("receiverId") long receiverId,
            @Param("senderId") long senderId
    );
}
