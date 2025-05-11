package com.eswap.repository;

import com.eswap.model.Transaction;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface TransactionRepository extends JpaRepository<Transaction, Long> {
    Optional<Transaction> findByOrderIdAndType(String orderId, Transaction.TransactionType transactionType);
}
