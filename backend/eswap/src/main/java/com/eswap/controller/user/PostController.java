package com.eswap.controller.user;

import com.eswap.common.ApiResponse;
import com.eswap.common.constants.PageResponse;
import com.eswap.request.AddPostRequest;
import com.eswap.response.PostResponse;
import com.eswap.service.PostService;
import jakarta.validation.Valid;
import lombok.RequiredArgsConstructor;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

@RestController
@RequestMapping("posts")
@RequiredArgsConstructor
public class PostController {
    private final PostService postService;

    @PostMapping(value = "/add", consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse> addPost(
            @Valid @RequestPart("post") AddPostRequest request,
            @RequestPart(value = "mediaFiles", required = false) MultipartFile[] mediaFiles,
            Authentication auth) {

        postService.addPost(auth, request, mediaFiles);
        return ResponseEntity.ok(new ApiResponse(true, "Đăng bài thành công!", null));
    }

    @GetMapping
    public ResponseEntity<ApiResponse> getAllPosts(
            Authentication connectedUser,
            @RequestParam(name = "page", defaultValue = "0", required = false) int page,
            @RequestParam(name = "size", defaultValue = "10", required = false) int size
    ) {
        PageResponse<PostResponse> postResponses = postService.getAllPosts(connectedUser, page, size);

        return ResponseEntity.ok(new ApiResponse(true, "Get all posts success", postResponses));
    }
}
