package com.eswap.repository;

import com.eswap.model.Chat;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface ChatRepository extends JpaRepository<Chat, Long> {
    @Query("""
                SELECT c FROM Chat c
                WHERE (c.user1.id = :user1Id AND c.user2.id = :user2Id)
                   OR (c.user1.id = :user2Id AND c.user2.id = :user1Id)
            """)
    Chat findChatBetweenUsers(@Param("user1Id") long user1Id, @Param("user2Id") long user2Id);
}
