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
import java.util.Optional;

@Repository
public interface PostRepository extends JpaRepository<Post, Long> {

    @Query("""
            SELECT p FROM Post p
                     WHERE p.id = :id AND p.status!=com.eswap.common.constants.PostStatus.DELETED
                           AND (
                                p.user = :user
                                OR(
                                    p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    AND (
                                            p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                                            OR (
                                                   p.user in(
                                                   SELECT f.followee FROM Follow f
                                                   WHERE f.follower = :user and f.waitConfirm=false
                                                )
                                            )
                                    )
                                )
                           )
            """)
    Optional<Post> findByIdAndConnectedUser(@Param("id") long id, @Param("user") User user);

    @Query("""
            SELECT p FROM Post p
                        WHERE p.user = :user AND p.status!=com.eswap.common.constants.PostStatus.DELETED
                               AND (p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    OR :user in(
                                       SELECT f.followee FROM Follow f
                                       WHERE f.follower = :connectedUser and f.waitConfirm=false
                                    )     
                               )
                               AND p.quantity > p.sold
            """)
    Page<Post> getShowingPosts(@Param("connectedUser") User connectedUser, @Param("user") User user, Pageable pageable);

    @Query("""
            SELECT p FROM Post p
                        WHERE p.user = :user AND p.status!=com.eswap.common.constants.PostStatus.DELETED
                               AND (p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    OR :user in(
                                       SELECT f.followee FROM Follow f
                                       WHERE f.follower = :connectedUser and f.waitConfirm=false
                                    )     
                               )
                               AND p.sold > 0
            """)
    Page<Post> getSoldPosts(@Param("connectedUser") User connectedUser, @Param("user") User user, Pageable pageable);

    @Query("""
                SELECT p FROM Post p
                            WHERE p.status!=com.eswap.common.constants.PostStatus.DELETED
                              AND (:isOnlyShop = false OR p.user.role.name = com.eswap.common.constants.RoleType.STORE)
                              AND p.user != :user
                               AND p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                               AND (p.user in(
                                       SELECT f.followee FROM Follow f
                                       WHERE f.follower = :user and f.waitConfirm=false
                                    )
                                    OR 
                                        p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                )
                               AND (:keyword IS NULL OR p.name LIKE %:keyword% OR p.user.firstName LIKE %:keyword% OR p.user.lastName LIKE %:keyword%)
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
                            WHERE p.status!=com.eswap.common.constants.PostStatus.DELETED 
                               AND p.user != :user
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
                                    AND p.user != :user
                                    AND p.status!=com.eswap.common.constants.PostStatus.DELETED
                                    AND (:isOnlyShop = false OR p.user.role.name = com.eswap.common.constants.RoleType.STORE)
                                    AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    AND (p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                                        OR p.user in(
                                           SELECT f.followee FROM Follow f
                                           WHERE f.follower = :user and f.waitConfirm=false
                                        ))
                           AND (:keyword IS NULL OR p.name LIKE %:keyword% OR p.user.firstName LIKE %:keyword% OR p.user.lastName LIKE %:keyword%)
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

//    @Query("""
//            select p from Post p
//            where p.user in (
//                select f.followee from Follow f
//                where f.follower = :user and f.waitConfirm = false
//                       AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
//                )
//                and p.status!=com.eswap.common.constants.PostStatus.DELETED
//                order by p.createdAt desc
//            """)

    @Query("""
            SELECT p FROM Post p 
                        WHERE 
                                    p.user != :user
                                    AND p.status!=com.eswap.common.constants.PostStatus.DELETED
                                    AND (p.user in (
                                    select f.followee from Follow f
                                    where f.follower = :user and f.waitConfirm = false
                                           AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    )
                                    OR (p.educationInstitution = :educationInstitution
                                    AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    AND (p.privacy=com.eswap.common.constants.Privacy.PUBLIC)))
                            ORDER BY p.createdAt desc
            """)
    Page<Post> findByFollowingOrEducationInstitution(@Param("user") User user, @Param("educationInstitution") EducationInstitution educationInstitution, Pageable pageable);


    @Query("""
            SELECT p FROM Post p 
                        WHERE p.educationInstitution = :educationInstitution 
                                    AND p.user != :user
                                    AND p.status!=com.eswap.common.constants.PostStatus.DELETED
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
                                    AND p.user != :user
                                    AND p.status!=com.eswap.common.constants.PostStatus.DELETED
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
                                    AND p.user != :user
                                    AND p.status!=com.eswap.common.constants.PostStatus.DELETED
                                    AND (:isOnlyShop = false OR p.user.role.name = com.eswap.common.constants.RoleType.STORE)
                                    AND p.status=com.eswap.common.constants.PostStatus.PUBLISHED
                                    AND (p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                                        OR p.user in(
                                           SELECT f.followee FROM Follow f
                                           WHERE f.follower = :user and f.waitConfirm=false
                                        ))
                                    AND (:keyword IS NULL OR p.name LIKE %:keyword% OR p.user.firstName LIKE %:keyword% OR p.user.lastName LIKE %:keyword%)
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
                and p.status!=com.eswap.common.constants.PostStatus.DELETED
                order by p.createdAt desc
            """)
    Page<Post> findPostsOfFollowing(User user, Pageable pageable);

    @Query("""
            SELECT COUNT(p) FROM Post p
            WHERE p.status!=com.eswap.common.constants.PostStatus.DELETED AND p.user = :user
            """)
    Integer countPostsByUser(@Param("user") User user);

    @Query("""
                SELECT p FROM Post p
                WHERE p.status = com.eswap.common.constants.PostStatus.PUBLISHED
                  AND p.status != com.eswap.common.constants.PostStatus.DELETED
                   AND (p.privacy=com.eswap.common.constants.Privacy.PUBLIC
                      OR p.user in(
                         SELECT f.followee FROM Follow f
                         WHERE f.follower = :user and f.waitConfirm=false
                      ))
                  AND p.user != :user
                  AND (
                      (:word1 IS NULL AND :word2 IS NULL AND :word3 IS NULL AND :word4 IS NULL AND :word5 IS NULL)
                      OR (p.name LIKE %:word1% OR p.name LIKE %:word2% OR p.name LIKE %:word3% OR p.name LIKE %:word4% OR p.name LIKE %:word5%)
                      OR (p.description LIKE %:word1% OR p.description LIKE %:word2% OR p.description LIKE %:word3% OR p.description LIKE %:word4% OR p.description LIKE %:word5%)
                      OR p.category IN (
                          SELECT p2.category FROM Post p2
                          WHERE (p2.name LIKE %:word1% OR p2.name LIKE %:word2% OR p2.name LIKE %:word3% OR p2.name LIKE %:word4% OR p2.name LIKE %:word5%)
                            AND p2.status = com.eswap.common.constants.PostStatus.PUBLISHED
                      )
                  )
                ORDER BY 
                    CASE WHEN (:word1 IS NOT NULL OR :word2 IS NOT NULL OR :word3 IS NOT NULL OR :word4 IS NOT NULL OR :word5 IS NOT NULL) THEN 
                        (CASE WHEN (p.name LIKE %:word1% OR p.description LIKE %:word1%) THEN 5 ELSE 0 END +
                         CASE WHEN (p.name LIKE %:word2% OR p.description LIKE %:word2%) THEN 4 ELSE 0 END +
                         CASE WHEN (p.name LIKE %:word3% OR p.description LIKE %:word3%) THEN 3 ELSE 0 END +
                         CASE WHEN (p.name LIKE %:word4% OR p.description LIKE %:word4%) THEN 2 ELSE 0 END +
                         CASE WHEN (p.name LIKE %:word5% OR p.description LIKE %:word5%) THEN 1 ELSE 0 END)
                    ELSE 0 END DESC,
                    p.createdAt DESC
            """)
    Page<Post> getRecommendUserPosts(
            @Param("user") User user,
            @Param("word1") String word1,
            @Param("word2") String word2,
            @Param("word3") String word3,
            @Param("word4") String word4,
            @Param("word5") String word5,
            Pageable pageable
    );


    @Query("""
            SELECT p FROM Post p
                        WHERE p.user = :store
                           AND p.status = com.eswap.common.constants.PostStatus.PENDING
            """)
    Page<Post> getPendingPosts(@Param("store") User store, Pageable pageable);

    @Query("""
            SELECT p FROM Post p
                        WHERE p.user = :store
                           AND p.status = com.eswap.common.constants.PostStatus.PUBLISHED
            """)
    Page<Post> getAcceptedPosts(@Param("store") User store, Pageable pageable);

    @Query("""
            SELECT p FROM Post p
                        WHERE p.user = :store
                           AND p.status = com.eswap.common.constants.PostStatus.REJECTED
            """)
    Page<Post> getRejectedPosts(@Param("store") User store, Pageable pageable);


    @Query("""
            SELECT p FROM Post p
                WHERE p.storeCustomer.id = :customerId
            """)
    Page<Post> getStorePostsForCustomer(@Param("customerId") long customerId, Pageable pageable);

    @Query("""
            SELECT p FROM Post p
                        WHERE p.id = :postId
                        AND p.user = :store
                        AND p.status = com.eswap.common.constants.PostStatus.PENDING
            """)
    Optional<Post> findPendingPostByIdAndStore(@Param("postId") long postId,@Param("store") User store);
}
