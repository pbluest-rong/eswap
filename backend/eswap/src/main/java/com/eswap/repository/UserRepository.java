package com.eswap.repository;

import com.eswap.model.User;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UserRepository extends JpaRepository<User, Long>, UserRepositoryCustom{
    Optional<User> findByUsername(String username);
    Optional<User> findByEmail(String email);
    Optional<User> findByPhoneNumber(String phoneNumber);
    boolean existsByUsername(String username);
    boolean existsByEmail(String email);
    boolean existsByPhoneNumber(String phoneNumber);
    // Nếu có keyword
    @Query("""
    SELECT u FROM User u
    WHERE (:keyword IS NULL 
        OR u.username = :keyword 
        OR u.email = :keyword 
        OR LOWER(u.firstName) LIKE LOWER(CONCAT('%', :keyword, '%')) 
        OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :keyword, '%')))
    ORDER BY 
        CASE WHEN u.username = :keyword THEN 0 ELSE 1 END,
        u.firstName ASC,
        u.lastName ASC
    """)
    Page<User> getUsersWithKeyword(@Param("keyword") String keyword, Pageable pageable);

    @Query("SELECT u FROM User u ORDER BY u.createdAt DESC")
    Page<User> getUsers(Pageable pageable);
    @Query("""
            SELECT u FROM User u
            WHERE u.role.name=com.eswap.common.constants.RoleType.STORE
            """)
    List<User> getStores();
}
