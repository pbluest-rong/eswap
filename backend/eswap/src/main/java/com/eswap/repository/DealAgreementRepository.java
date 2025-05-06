package com.eswap.repository;

import com.eswap.model.DealAgreement;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface DealAgreementRepository extends JpaRepository<DealAgreement, Long> {
    @Query("""
            SELECT d FROM DealAgreement d
                WHERE d.id = :id
                AND (d.buyer.id = :buyerId
                            OR d.buyer.id = :buyerId)
                AND d.post.user.id != :buyerId
            """)
    Optional<DealAgreement> findDealAgreementByIdAndBuyer(long id, long buyerId);

    @Query("""
            SELECT d FROM DealAgreement d
                WHERE d.post.id = :postId
                AND (d.buyer.id = :buyerId
                            OR d.buyer.id = :buyerId)
                AND d.post.user.id != :buyerId
            """)
    Optional<DealAgreement> findDealAgreement(@Param("postId") long postId, @Param("buyerId") long buyerId);

    @Query("""
            SELECT d FROM DealAgreement d
                WHERE d.post.id = :postId
                AND (d.buyer.id = :buyerId
                            OR d.buyer.id = :buyerId)
                AND d.post.user.id != :buyerId
                AND d.status = com.eswap.common.constants.DealAgreementStatus.WAITING
            """)
    Optional<DealAgreement> findWaitingDealAgreement(@Param("postId") long postId, @Param("buyerId") long buyerId);
}