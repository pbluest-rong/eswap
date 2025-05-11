package com.eswap.repository;

import com.eswap.model.Order;
import com.eswap.model.User;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;

import java.time.LocalDateTime;
import java.util.List;

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
}
