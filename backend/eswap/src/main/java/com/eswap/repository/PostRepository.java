package com.eswap.repository;

import com.eswap.common.constants.Condition;
import com.eswap.common.constants.SortPostType;
import com.eswap.model.*;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.math.BigDecimal;
import java.util.List;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {
    @Query("""
            SELECT p FROM Post p
                        WHERE p.user = :user AND p.isDeleted = false
                               AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                               AND p.privacy=com.eswap.common.constants.Privacy.PUBLIC
            """)
    Page<Post> getPublicPost(@Param("user") User user, Pageable pageable);

    @Query("""
            SELECT p FROM Post p
                        WHERE p.user = :user AND p.isDeleted = false
                               AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
            """)
    Page<Post> getPost(@Param("user") User user, Pageable pageable);


    @Query("""
                SELECT p FROM Post p
                            WHERE p.isDeleted=false
                              AND (:isOnlyShop = false OR p.user.role.name = com.eswap.common.constants.RoleType.SHOP)
                               AND p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                               AND (p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    OR p.user in(
                                       SELECT f.followee FROM Follow f
                                       WHERE f.follower = :user and f.waitConfirm=false
                                    )
                                )
                               AND (:keyword IS NULL OR p.name LIKE %:keyword%)
                               AND (:categoryIdList IS NULL OR p.category.id IN :categoryIdList)
                               AND (:brandIdList IS NULL OR p.brand.id IN :brandIdList)
                               AND (:minPrice IS NULL OR p.salePrice >= :minPrice)
                               AND (:maxPrice IS NULL OR p.salePrice <= :maxPrice)
                               AND (:condition IS NULL OR p.condition = :condition)
            """)
    Page<Post> getSuggestedPosts(@Param("user") User user,
                                 Pageable pageable,
                                 @Param("keyword") String keyword,
                                 @Param("categoryIdList") List<Long> categoryIdList,
                                 @Param("brandIdList") List<Long> brandIdList,
                                 @Param("minPrice") BigDecimal minPrice,
                                 @Param("maxPrice") BigDecimal maxPrice,
                                 @Param("condition") Condition condition,
                                 @Param("isOnlyShop") boolean isOnlyShop
    );

    @Query("""
                SELECT p FROM Post p
                            WHERE p.isDeleted=false 
                               AND p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                               AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    OR p.user in(
                                       SELECT f.followee FROM Follow f
                                       WHERE f.follower = :user and f.waitConfirm=false
                                    )
                            ORDER BY p.createdAt desc
            """)
    Page<Post> getSuggestedPosts(@Param("user") User user, Pageable pageable);

    @Query("""
            SELECT p FROM Post p 
                        WHERE p.educationInstitution = :educationInstitution 
                                    AND p.isDeleted = false
                                    AND (:isOnlyShop = false OR p.user.role.name = com.eswap.common.constants.RoleType.SHOP)
                                    AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    AND (p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                                        OR p.user in(
                                           SELECT f.followee FROM Follow f
                                           WHERE f.follower = :user and f.waitConfirm=false
                                        ))
                           AND (:keyword IS NULL OR p.name LIKE %:keyword%)
                           AND (:categoryIdList IS NULL OR p.category.id IN :categoryIdList)
                           AND (:brandIdList IS NULL OR p.brand.id IN :brandIdList)
                           AND (:minPrice IS NULL OR p.salePrice >= :minPrice)
                           AND (:maxPrice IS NULL OR p.salePrice <= :maxPrice)
                           AND (:condition IS NULL OR p.condition = :condition)
            """)
    Page<Post> findByEducationInstitution(@Param("user") User user,
                                          @Param("educationInstitution") EducationInstitution educationInstitution,
                                          Pageable pageable,
                                          @Param("keyword") String keyword,
                                          @Param("categoryIdList") List<Long> categoryIdList,
                                          @Param("brandIdList") List<Long> brandIdList,
                                          @Param("minPrice") BigDecimal minPrice,
                                          @Param("maxPrice") BigDecimal maxPrice,
                                          @Param("condition") Condition condition,
                                          @Param("isOnlyShop") boolean isOnlyShop
    );


    @Query("""
            SELECT p FROM Post p 
                        WHERE p.educationInstitution = :educationInstitution 
                                    AND p.isDeleted = false
                                    AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    AND (p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                                        OR p.user in(
                                           SELECT f.followee FROM Follow f
                                           WHERE f.follower = :user and f.waitConfirm=false
                                        ))
                            ORDER BY p.createdAt desc
            """)
    Page<Post> findByEducationInstitution(@Param("user") User user, @Param("educationInstitution") EducationInstitution educationInstitution, Pageable pageable);

    @Query("""
            SELECT p FROM Post p 
                        WHERE p.educationInstitution.province = :province 
                                    AND p.isDeleted = false
                                    AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    AND (p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                                        OR p.user in(
                                           SELECT f.followee FROM Follow f
                                           WHERE f.follower = :user and f.waitConfirm=false
                                        ))
                            ORDER BY p.createdAt desc
            """)
    Page<Post> findByProvince(@Param("user") User user, @Param("province") Province province, Pageable pageable);

    @Query("""
            SELECT p FROM Post p 
                        WHERE p.educationInstitution.province = :province 
                                    AND p.isDeleted = false
                                    AND (:isOnlyShop = false OR p.user.role.name = com.eswap.common.constants.RoleType.SHOP)
                                    AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    AND (p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                                        OR p.user in(
                                           SELECT f.followee FROM Follow f
                                           WHERE f.follower = :user and f.waitConfirm=false
                                        ))
                                    AND (:keyword IS NULL OR p.name LIKE %:keyword%)
                                    AND (:categoryIdList IS NULL OR p.category.id IN :categoryIdList)
                                    AND (:brandIdList IS NULL OR p.brand.id IN :brandIdList)
                                    AND (:minPrice IS NULL OR p.salePrice >= :minPrice)
                                    AND (:maxPrice IS NULL OR p.salePrice <= :maxPrice)
                                    AND (:condition IS NULL OR p.condition = :condition)
            """)
    Page<Post> findByProvince(@Param("user") User user,
                              @Param("province") Province province,
                              Pageable pageable,
                              @Param("keyword") String keyword,
                              @Param("categoryIdList") List<Long> categoryIdList,
                              @Param("brandIdList") List<Long> brandIdList,
                              @Param("minPrice") BigDecimal minPrice,
                              @Param("maxPrice") BigDecimal maxPrice,
                              @Param("condition") Condition condition,
                              @Param("isOnlyShop") boolean isOnlyShop);


    @Query("""
            select p from Post p
            where p.user in (
                select f.followee from Follow f
                where f.follower = :user and f.waitConfirm = false
                       AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                )
                and p.isDeleted = false
                order by p.createdAt desc
            """)
    Page<Post> findPostsOfFollowing(User user, Pageable pageable);
}
