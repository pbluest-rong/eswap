package com.eswap.service;

import com.eswap.model.Brand;
import com.eswap.model.Category;
import com.eswap.repository.CategoryRepository;
import com.eswap.request.AddCategoryRequest;
import com.eswap.request.GetBrandsByCategoriesRequest;
import com.eswap.response.BrandResponse;
import com.eswap.response.CategoryResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.util.HashSet;
import java.util.List;
import java.util.Optional;
import java.util.Set;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class CategoryService {
    private final CategoryRepository categoryRepository;

    public List<CategoryResponse> getAllCategories() {
        List<Category> rootCategories = categoryRepository.findByParentCategoryIsNull();
        return rootCategories.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());
    }

    private CategoryResponse convertToResponse(Category category) {
        List<Category> children = categoryRepository.findByParentCategoryId(category.getId());
        List<CategoryResponse> childResponses = children.stream()
                .map(this::convertToResponse)
                .collect(Collectors.toList());

        return new CategoryResponse(
                category.getId(),
                category.getName(),
                childResponses,
                category.getBrands()
        );
    }


    public Optional<CategoryResponse> getCategoryById(Long id) {
        return categoryRepository.findById(id)
                .map(this::convertToResponse);
    }

    public Set<Long> getAllCategoryIds(List<Long> selectedCategoryIds) {
        Set<Long> allCategoryIds = new HashSet<>();

        for (Long id : selectedCategoryIds) {
            allCategoryIds.add(id);
            collectChildIdsRecursively(id, allCategoryIds);
        }

        return allCategoryIds;
    }

    private void collectChildIdsRecursively(Long parentId, Set<Long> collectedIds) {
        List<Category> children = categoryRepository.findByParentCategoryId(parentId);
        for (Category child : children) {
            if (collectedIds.add(child.getId())) {
                collectChildIdsRecursively(child.getId(), collectedIds);
            }
        }
    }

    public List<BrandResponse> getBrandsByCategoryList(GetBrandsByCategoriesRequest request) {
        List<Brand> brands = categoryRepository.getBrandsByCategoryList(request.getCategoryIdList());
        List<BrandResponse> responses = brands.stream()
                .map(brand -> new BrandResponse(brand.getId(), brand.getName()))
                .collect(Collectors.toList());
        return responses;
    }

    public List<BrandResponse> getBrandsByCategoryId(long categoryId) {
        List<Brand> brands = categoryRepository.findBrandsByCategoryId(categoryId);
        List<BrandResponse> responses = brands.stream()
                .map(brand -> new BrandResponse(brand.getId(), brand.getName()))
                .collect(Collectors.toList());
        return responses;
    }

    public Category addCategory(AddCategoryRequest request) {
        Category category = new Category();
        category.setName(request.getName());

        if (request.getParentCategoryId() != null) {
            Category parentCategory = categoryRepository.findById(request.getParentCategoryId())
                    .orElseThrow(() -> new IllegalArgumentException("Parent category not found"));
            category.setParentCategory(parentCategory);
        }

        return categoryRepository.save(category);
    }
}
