package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.model.Category;
import com.eswap.request.GetBrandsByCategoriesRequest;
import com.eswap.response.BrandResponse;
import com.eswap.response.CategoryResponse;
import com.eswap.service.CategoryService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("categories")
@RequiredArgsConstructor
public class CategoryController {
    private final CategoryService categoryService;

    @GetMapping
    public ResponseEntity<ApiResponse> getAllCategories() {
        List<CategoryResponse> categories = categoryService.getAllCategories();
        return ResponseEntity.ok(new ApiResponse(true,"Fetched categories successfully", categories));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse> getCategoryById(@PathVariable Long id) {
        return categoryService.getCategoryById(id)
                .map(category -> ResponseEntity.ok(new ApiResponse(true,"Fetched category successfully", category)))
                .orElseGet(() -> ResponseEntity.badRequest().body(new ApiResponse(false,"Category not found", null)));
    }

    @GetMapping("/brands")
    public ResponseEntity<ApiResponse> getBrandsByCategoryList(@RequestBody GetBrandsByCategoriesRequest request) {
        List<BrandResponse> brands = categoryService.getBrandsByCategoryList(request);
        return ResponseEntity.ok(new ApiResponse(true,"Fetched brands successfully", brands));
    }

    @GetMapping("/{categoryId}/brands")
    public ResponseEntity<ApiResponse> getBrandsByCategoryId(@PathVariable("categoryId") long categoryId) {
        List<BrandResponse> brands = categoryService.getBrandsByCategoryId(categoryId);
        return ResponseEntity.ok(new ApiResponse(true,"Fetched brands successfully", brands));
    }
}
