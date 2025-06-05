package com.eswap.controller.admin;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.PageResponse;
import com.eswap.model.Brand;
import com.eswap.model.Category;
import com.eswap.model.UserBalance;
import com.eswap.response.CategoryResponse;
import com.eswap.response.PostResponse;
import com.eswap.response.UserBalanceResponse;
import com.eswap.response.UserResponse;
import com.eswap.service.BalanceService;
import com.eswap.service.BrandService;
import com.eswap.service.CategoryService;
import com.eswap.service.UserService;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("admin")
@RequiredArgsConstructor
public class AdminController {
    private final UserService userService;
    private final BalanceService balanceService;

    @GetMapping("/users")
    public ResponseEntity<ApiResponse> getUsers(Authentication auth,
                                                @RequestParam(name = "keyword", required = false)
                                                @Size(min = 3, message = "Keyword phải có ít nhất 3 ký tự")
                                                @Pattern(regexp = ".*\\S.*", message = "Keyword không được chỉ chứa khoảng trắng")
                                                String keyword,
                                                @RequestParam(defaultValue = "0") int page,
                                                @RequestParam(defaultValue = "10") int size) {
        PageResponse<UserResponse> users = userService.getUsersForAdmin(auth, keyword, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "success", users));
    }

    @PutMapping("/users/lock-user/{id}")
    public ResponseEntity<ApiResponse> lockUser(@PathVariable("id") long id, Authentication authentication) {
        userService.lockedUserByAdmin(authentication, id);
        return ResponseEntity.ok(new ApiResponse(true, "Locked user successfully", null));
    }

    @PutMapping("/users/unlock-user/{id}")
    public ResponseEntity<ApiResponse> unlockUser(@PathVariable("id") long id, Authentication authentication) {
        userService.unLockedUserByAdmin(authentication, id);
        return ResponseEntity.ok(new ApiResponse(true, "Unlocked user successfully", null));
    }

    @GetMapping("/balances")
    public ResponseEntity<ApiResponse> getBalances(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        PageResponse<UserBalanceResponse> balances = balanceService.getBalances(page, size);
        return ResponseEntity.ok(new ApiResponse(true, "balances", balances));
    }

    @GetMapping("/balances/request-withdrawal")
    public ResponseEntity<ApiResponse> getRequestWithdrawalBalances(
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        PageResponse<UserBalanceResponse> balances = balanceService.getRequestWithdrawalBalances(page, size);
        return ResponseEntity.ok(new ApiResponse(true, "balances", balances));
    }


    @PutMapping("/balances/accept-withdrawal/{userId}")
    public ResponseEntity<ApiResponse> acceptWithdrawal(@PathVariable("userId") long userId) {
        UserBalanceResponse balanceResponse = balanceService.adminAcceptWithdrawal(userId);
        return ResponseEntity.ok(new ApiResponse(true, "Accept withdrawal for user successfully", balanceResponse));
    }
}
