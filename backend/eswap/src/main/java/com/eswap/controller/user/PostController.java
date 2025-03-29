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
@RequestMapping("/posts")
@RequiredArgsConstructor
public class PostController {
    private final PostService postService;

    @PostMapping(consumes = MediaType.MULTIPART_FORM_DATA_VALUE)
    public ResponseEntity<ApiResponse> addPost(
            @Valid @RequestPart("post") AddPostRequest request,
            @RequestPart(value = "mediaFiles", required = false) MultipartFile[] mediaFiles,
            Authentication auth) {

        postService.addPost(auth, request, mediaFiles);
        return ResponseEntity.ok(new ApiResponse(true, "Đăng bài thành công!", null));
    }

    @GetMapping
    public ResponseEntity<ApiResponse> getAllPosts(
            @RequestParam(required = false) Long userId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        PageResponse<PostResponse> postResponses = (userId == null)
                ? postService.getAllPosts(page, size)
                : postService.getUserPosts(userId, page, size);

        return ResponseEntity.ok(new ApiResponse(true, "Posts retrieved successfully", postResponses));
    }

    @GetMapping("/me")
    public ResponseEntity<ApiResponse> getOwnPosts(
            Authentication connectedUser,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        PageResponse<PostResponse> postResponses = postService.getOwnPosts(connectedUser, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Your posts retrieved successfully", postResponses));
    }

    @GetMapping("/education-institutions/{educationInstitutionId}")
    public ResponseEntity<ApiResponse> getPostsByEducationInstitution(
            @PathVariable long educationInstitutionId,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "10") int size
    ) {
        PageResponse<PostResponse> postResponses = postService.getPostsByEducationInstitution(educationInstitutionId, page, size);
        return ResponseEntity.ok(new ApiResponse(true, "Posts retrieved successfully for the education institution", postResponses));
    }
}
