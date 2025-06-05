package com.eswap.repository;

import com.eswap.model.Order;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

public interface OrderRepository extends JpaRepository<Order, String> {
    List<Order> findByStatusAndCreatedAtBefore(Order.OrderStatus orderStatus, LocalDateTime localDateTime, PageRequest pageRequest);

    @Query("""
            SELECT o FROM Order o
            WHERE o.id = :id AND o.seller.id = :sellerId
            """)
    Order findByIdAndSeller(String id, long sellerId);

    @Query("""
            SELECT o FROM Order o
            WHERE o.id = :id AND o.buyer.id = :buyerId
            """)
    Order findByIdAndBuyer(String id, long buyerId);

    @Query("""
            SELECT o FROM Order o
            WHERE o.post.id = :postId AND o.buyer.id = :buyerId
                        AND o.status = com.eswap.model.Order.OrderStatus.PENDING 
                        OR o.status = com.eswap.model.Order.OrderStatus.AWAITING_DEPOSIT
            """)
    Order findByPostAndBuyerUnprocessed(long postId, long buyerId);

    @Query("""
            SELECT o FROM Order o
                WHERE o.buyer.id = :userId
                AND o.status = :status
            """)
    Page<Order> getBuyerOrders(long userId, Order.OrderStatus status, Pageable pageable);

    @Query("""
            SELECT o FROM Order o
                WHERE o.seller.id = :userId
                AND o.status = :status
            """)
    Page<Order> getSellerOrders(@Param("userId") long userId,
                                @Param("status") Order.OrderStatus status,
                                Pageable pageable);

    @Query("""
            SELECT o FROM Order o
                WHERE 
                (o.seller.id = :userId
                OR o.buyer.id = :userId)
                AND (
                o.id like :keyword
                OR o.seller.firstName like %:keyword%
                OR o.seller.lastName like %:keyword%
                OR o.post.name like %:keyword%       
                )
            """)
    Page<Order> findOrders(@Param("userId") long userId, @Param("keyword") String keyword,
                           Pageable pageable);
    @Query("""
            SELECT COUNT(o) FROM Order o
            WHERE o.buyer.id = :userId
                AND o.status = :status
            """)
    Integer countBuyerOrdersByStatus(@Param("userId") Long userId, @Param("status") Order.OrderStatus status);

    @Query("""
            SELECT COUNT(o) FROM Order o
            WHERE o.seller.id = :userId
                AND o.status = :status
            """)
    Integer countSellerOrdersByStatus(@Param("userId") Long userId, @Param("status") Order.OrderStatus status);

    Optional<Order> findByPaymentTransactionId(String orderId);
}
