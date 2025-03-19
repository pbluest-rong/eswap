package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.model.*;
import com.eswap.repository.*;
import com.eswap.request.AddPostRequest;
import com.eswap.service.upload.UploadService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class PostService {
    private final PostRepository postRepository;
    private final EducationInstitutionRepository educationInstitutionRepository;
    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;
    private final PostMediaRepository postMediaRepository;
    private final UploadService uploadService;

    @Transactional
    public void addPost(AddPostRequest request, Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();

        // Lấy entity liên quan từ database
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));

        Brand brand = brandRepository.findById(request.getBrandId())
                .orElseThrow(() -> new IllegalArgumentException("Brand not found"));

        EducationInstitution educationInstitution = null;
        if (request.getEducationInstitutionId() != null) {
            educationInstitution = educationInstitutionRepository.findById(request.getEducationInstitutionId())
                    .orElseThrow(() -> new IllegalArgumentException("Education Institution not found"));
        }

        // Tạo mới Post
        Post post = new Post();
        post.setName(request.getName());
        post.setDescription(request.getDescription());
        post.setUser(user);
        post.setCategory(category);
        post.setBrand(brand);
        post.setEducationInstitution(educationInstitution);
        post.setOriginalPrice(request.getOriginalPrice());
        post.setSalePrice(request.getSalePrice());
        post.setQuantity(request.getQuantity());
        post.setAvailableTime(request.getAvailableTime());
        post.setStatus(request.getStatus());
        post.setPrivacy(request.getPrivacy());
        post.setDeleted(false);
        // Lưu Post vào database
        post = postRepository.save(post);
    }

    public void uploadMedia(Long postId, MultipartFile[] mediaFiles) {
        Post post = postRepository.findById(postId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.POST_NOT_FOUND, "id", postId));
        for (MultipartFile file : mediaFiles) {
            String url = uploadService.upload(file);
            if (url != null){
                PostMedia postMedia = new PostMedia();
                postMedia.setOriginalUrl(url);
                postMedia.setContentType(file.getContentType());
                postMedia.setPost(post);
                postMediaRepository.save(postMedia);
            }
        }
    }
}
