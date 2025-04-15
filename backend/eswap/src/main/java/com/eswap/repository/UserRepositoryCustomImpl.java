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
    public Page<User> searchUsersWithPriority(User currentUser, String keyword, Pageable pageable) {
        String baseQuery = """
        FROM User u
        LEFT JOIN Follow f1 ON f1.follower = :currentUser AND f1.followee = u
        LEFT JOIN Follow f2 ON f2.follower = u AND f2.followee = :currentUser
        WHERE u.username = :keyword
           OR LOWER(u.firstName) LIKE LOWER(CONCAT('%', :keyword, '%'))
           OR LOWER(u.lastName) LIKE LOWER(CONCAT('%', :keyword, '%'))
    """;

        String selectQuery = "SELECT u " + baseQuery + """
        ORDER BY
          CASE WHEN u.username = :keyword THEN 1 ELSE 0 END DESC,
          CASE WHEN f1.id IS NOT NULL OR f2.id IS NOT NULL THEN 1 ELSE 0 END DESC,
          u.firstName ASC
    """;

        TypedQuery<User> query = entityManager.createQuery(selectQuery, User.class);
        query.setParameter("keyword", keyword);
        query.setParameter("currentUser", currentUser);
        query.setFirstResult((int) pageable.getOffset());
        query.setMaxResults(pageable.getPageSize());
        List<User> resultList = query.getResultList();

        // Đếm total
        String countQueryStr = "SELECT COUNT(u) " + baseQuery;
        TypedQuery<Long> countQuery = entityManager.createQuery(countQueryStr, Long.class);
        countQuery.setParameter("keyword", keyword);
        countQuery.setParameter("currentUser", currentUser);
        Long total = countQuery.getSingleResult();

        return new PageImpl<>(resultList, pageable, total);
    }

}
