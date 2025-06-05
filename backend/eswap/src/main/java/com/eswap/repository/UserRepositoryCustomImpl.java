package com.eswap.repository;

import com.eswap.model.User;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;
import jakarta.persistence.TypedQuery;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public class UserRepositoryCustomImpl implements UserRepositoryCustom {

    @PersistenceContext
    private EntityManager entityManager;

    @Override
    public Page<User> searchUsersWithPriority(User currentUser, String keyword, Boolean isGetFollowersOrFollowing, Pageable pageable) {
        String baseQuery = """
                    FROM User u
                    LEFT JOIN Follow f1 ON f1.follower = :currentUser AND f1.followee = u
                    LEFT JOIN Follow f2 ON f2.follower = u AND f2.followee = :currentUser
                    WHERE  u.role.name != com.eswap.common.constants.RoleType.ADMIN
                         AND (u.username = :keyword
                         OR LOWER(u.firstName) LIKE LOWER(CONCAT('%', :keyword, '%'))
                         OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :keyword, '%')))
                       
                """;

        // Xử lý điều kiện tìm kiếm keyword
        if (keyword != null && !keyword.trim().isEmpty()) {
            baseQuery += " AND (u.username = :keyword " +
                    "OR LOWER(u.firstName) LIKE LOWER(CONCAT('%', :keyword, '%')) " +
                    "OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :keyword, '%')))";
        }
//        // Thêm điều kiện lọc theo follower/following
        if (isGetFollowersOrFollowing != null) {
            if (isGetFollowersOrFollowing) {
                baseQuery += " AND EXISTS (SELECT 1 FROM Follow f WHERE f.followee = :currentUser AND f.follower = u)";
            } else {
                baseQuery += " AND EXISTS (SELECT 1 FROM Follow f WHERE f.follower = :currentUser AND f.followee = u)";
            }
        }

        String selectQuery = "SELECT u " + baseQuery.toString() + """
                ORDER BY
                  CASE WHEN :keyword IS NOT NULL AND u.username = :keyword THEN 1 ELSE 0 END DESC,
                  CASE WHEN EXISTS (SELECT 1 FROM Follow f WHERE (f.follower = :currentUser AND f.followee = u) OR 
                                                               (f.follower = u AND f.followee = :currentUser)) 
                       THEN 1 ELSE 0 END DESC,
                  u.firstName ASC
                """;

        TypedQuery<User> query = entityManager.createQuery(selectQuery, User.class);
        if (keyword != null && !keyword.trim().isEmpty()) {
            query.setParameter("keyword", keyword);
        } else {
            query.setParameter("keyword", "");
        }
        query.setParameter("currentUser", currentUser);
        query.setFirstResult((int) pageable.getOffset());
        query.setMaxResults(pageable.getPageSize());
        List<User> resultList = query.getResultList();

        // Đếm total
        String countQueryStr = "SELECT COUNT(u) " + baseQuery;
        TypedQuery<Long> countQuery = entityManager.createQuery(countQueryStr, Long.class);
        if (keyword != null && !keyword.trim().isEmpty()) {
            countQuery.setParameter("keyword", keyword);
        } else {
            countQuery.setParameter("keyword", "");
        }
        countQuery.setParameter("currentUser", currentUser);
        Long total = countQuery.getSingleResult();

        return new PageImpl<>(resultList, pageable, total);
    }

}
