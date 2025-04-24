package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.PageResponse;
import com.eswap.response.AuthenticationResponse;
import com.eswap.response.UserResponse;
import com.eswap.service.UserService;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @GetMapping
    public ResponseEntity<ApiResponse> findUser(Authentication auth,
                                                @RequestParam(name = "keyword")
                                                @Size(min = 3, message = "Keyword phải có ít nhất 3 ký tự")
                                                @Pattern(regexp = ".*\\S.*", message = "Keyword không được chỉ chứa khoảng trắng")
                                                String keyword,
                                                @RequestParam(defaultValue = "0") int page,
                                                @RequestParam(defaultValue = "10") int size) {

        PageResponse<UserResponse> usersResponse = userService.findUser(auth, keyword, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Find user successfully", usersResponse));
    }
    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse> getUser(@PathVariable int id, Authentication auth) {
        UserResponse userResponse = userService.getUserById(id, auth);
        return ResponseEntity.ok(new ApiResponse(true, "Get user successfully", userResponse));
    }
}
