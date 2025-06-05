package com.eswap.repository;

import com.eswap.model.UserBalance;
import io.micrometer.core.instrument.config.validate.Validated;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.util.Optional;

public interface UserBalanceRepository extends JpaRepository<UserBalance, Long> {
    @Query(
            """
                    SELECT b FROM UserBalance b
                    ORDER BY b.withdrawDateTime ASC
                    """
    )
    Page<UserBalance> getBalances(Pageable pageable);

    @Query("""
            select b from UserBalance b
                    where b.userId = :userId
        """)
    Optional<UserBalance> findByUserId(long userId);

    @Query(
            """
                    SELECT b FROM UserBalance b
                    WHERE b.isWithdrawRequested=true
                    ORDER BY b.withdrawDateTime ASC
                    """
    )
    Page<UserBalance> getRequestWithdrawalBalances(Pageable pageable);
}
