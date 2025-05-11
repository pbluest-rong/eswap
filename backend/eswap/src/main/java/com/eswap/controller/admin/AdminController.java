package com.eswap.controller.admin;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.PageResponse;
import com.eswap.model.Brand;
import com.eswap.model.Category;
import com.eswap.response.CategoryResponse;
import com.eswap.response.UserResponse;
import com.eswap.service.BrandService;
import com.eswap.service.CategoryService;
import com.eswap.service.UserService;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("admin")
@RequiredArgsConstructor
public class AdminController {
    private final BrandService brandService;
    private final CategoryService categoryService;
    private final UserService userService;

    @GetMapping("/users")
    public ResponseEntity<ApiResponse> getUsers(String keyword, int page, int size) {
        PageResponse<UserResponse> users = userService.getUsersForAdmin(keyword, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "success", users));
    }
    @PostMapping("/users/lock-user")
    public ResponseEntity<ApiResponse> lockUser(@RequestParam @Email(message = "Email is not formatted")
                                                @NotEmpty(message = "Email is mandatory") String userEmail, Authentication authentication) {
        userService.lockedUserByAdmin(authentication, userEmail);
        return ResponseEntity.ok(new ApiResponse(true, "Locked user successfully", null));
    }

    @PostMapping("/users/unlock-user")
    public ResponseEntity<ApiResponse> unlockUser(@RequestParam @Email(message = "Email is not formatted")
                                                  @NotEmpty(message = "Email is mandatory") String userEmail, Authentication authentication) {
        userService.unLockedUserByAdmin(authentication, userEmail);
        return ResponseEntity.ok(new ApiResponse(true, "Unlocked user successfully", null));
    }
    @PostMapping("/brands/add")
    public ResponseEntity<ApiResponse> createBrand(@RequestBody Brand brand) {
        Brand savedBrand = brandService.saveBrand(brand);
        return ResponseEntity.ok(new ApiResponse(true, "Created brand successfully", savedBrand));
    }

    @DeleteMapping("/brands/delete/{id}")
    public ResponseEntity<ApiResponse> deleteBrand(@PathVariable Long id) {
        brandService.deleteBrand(id);
        return ResponseEntity.ok(new ApiResponse(true, "Deleted brand successfully", null));
    }

    @PostMapping("/categories/add")
    public ResponseEntity<ApiResponse> createCategory(@RequestBody Category category) {
        categoryService.saveCategory(category);
        return ResponseEntity.ok(new ApiResponse(true, "Created category successfully", null));
    }

    @DeleteMapping("/categories/delete/{id}")
    public ResponseEntity<ApiResponse> deleteCategory(@PathVariable Long id) {
        categoryService.deleteCategory(id);
        return ResponseEntity.ok(new ApiResponse(true, "Deleted category successfully", null));
    }
}
