package com.eswap.repository;

import com.eswap.model.Brand;
import com.eswap.model.Category;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface CategoryRepository extends JpaRepository<Category, Long> {
    List<Category> findByParentCategoryId(Long parentId);

    List<Category> findByParentCategoryIsNull();

    @Query("""
                SELECT DISTINCT b FROM Brand b
                JOIN b.categories c
                WHERE (:categoryIdList IS NULL OR c.id IN :categoryIdList)
            """)
    List<Brand> getBrandsByCategoryList(List<Long> categoryIdList);
    @Query("""
                SELECT DISTINCT b FROM Brand b
                JOIN b.categories c
                WHERE (c.id = :categoryId)
            """)
    List<Brand> findBrandsByCategoryId(@Param("categoryId") Long categoryId);
}
