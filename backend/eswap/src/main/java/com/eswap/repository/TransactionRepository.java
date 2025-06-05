package com.eswap.repository;

import com.eswap.model.Transaction;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    @Query("""
            SELECT t FROM Transaction t
            WHERE t.receiver.id = :userId
            ORDER BY t.createdAt DESC
            """)
    Page<Transaction> getTransactions(long userId, Pageable pageable);
}
