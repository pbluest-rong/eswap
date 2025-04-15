package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.PageResponse;
import com.eswap.response.SimpleUserResponse;
import com.eswap.service.UserService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("users")
@RequiredArgsConstructor
public class UserController {
    private final UserService userService;

    @GetMapping
    public ResponseEntity<ApiResponse> findUser(Authentication auth,
                                                @RequestParam(required = false, name = "keyword") String keyword,
                                                @RequestParam(defaultValue = "0") int page,
                                                @RequestParam(defaultValue = "10") int size) {
        if (keyword == null || keyword.isEmpty()) {
//            PageResponse<SimpleUserResponse> usersResponse = userService.findUser(auth, keyword, page, size);
            return ResponseEntity.ok(new ApiResponse(true, "Find user successfully", null));
        } else {
            PageResponse<SimpleUserResponse> usersResponse = userService.findUser(auth, keyword, page, size);
            return ResponseEntity.ok(new ApiResponse(true, "Find user successfully", usersResponse));
        }
    }
}
