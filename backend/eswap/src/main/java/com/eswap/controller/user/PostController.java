package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.request.AddPostRequest;
import com.eswap.service.PostService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("posts")
@RequiredArgsConstructor
public class PostController {
    private final PostService postService;

    @PostMapping("/add")
    public ResponseEntity<ApiResponse> addPost(
            @Valid @RequestBody AddPostRequest request,
            Authentication auth) {
        postService.addPost(request, auth);
        return ResponseEntity.ok(new ApiResponse(true, "Đăng bài thành công!", null));
    }

    @PostMapping("/{postId}/upload")
    public ResponseEntity<ApiResponse> uploadMedia(
            @PathVariable Long postId,
            @RequestParam("mediaFiles") MultipartFile[] mediaFiles) {
        postService.uploadMedia(postId, mediaFiles);
        return ResponseEntity.ok(new ApiResponse(true, "Tải ảnh lên thành công!", null));
    }

}
