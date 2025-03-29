package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.constants.PageResponse;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.kafka.post.PostProducer;
import com.eswap.model.*;
import com.eswap.repository.*;
import com.eswap.request.AddPostRequest;
import com.eswap.response.PostResponse;
import com.eswap.service.upload.UploadService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
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
    private final PostProducer postProducer;
    private final LikeRepository likeRepository;
    private final UserRepository userRepository;

    @Transactional
    public void addPost(
            Authentication connectedUser,
            AddPostRequest request,
            MultipartFile[] mediaFiles) {
        User user = (User) connectedUser.getPrincipal();

        // Lấy entity liên quan từ database
        Category category = categoryRepository.findById(request.getCategoryId())
                .orElseThrow(() -> new IllegalArgumentException("Category not found"));

        Brand brand = (request.getBrandId() != null) ? brandRepository.findById(request.getBrandId())
                .orElseThrow(() -> new IllegalArgumentException("Brand not found")) : null;

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
        // upload ảnh
        List<PostMedia> mediaList = new ArrayList<>();
        for (MultipartFile file : mediaFiles) {
            String url = uploadService.upload(file);
            if (url != null) {
                PostMedia postMedia = new PostMedia();
                postMedia.setOriginalUrl(url);
                postMedia.setContentType(file.getContentType());
                postMedia.setPost(post);
                mediaList.add(postMedia);
            }
        }
        post.setMedia(mediaList);
        postRepository.save(post);
        // 5. Gửi thông báo tới Kafka
        postProducer.sendPostCreatedEvent(PostResponse.mapperToResponse(post, user.getFirstName(), user.getLastName(), user.getAvatarUrl(), 0));
    }

    public PageResponse<PostResponse> getAllPosts(int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.findAll(pageable);

        List<PostResponse> postResponses = posts.stream()
                .map(post -> {
                    int likeNumber = likeRepository.countByPostId(post.getId());
                    return PostResponse.mapperToResponse(post, post.getUser().getFirstName(),
                            post.getUser().getLastName(), post.getUser().getAvatarUrl(), likeNumber
                    );
                })
                .collect(Collectors.toList());

        return new PageResponse<>(
                postResponses,
                posts.getNumber(),
                posts.getSize(),
                (int) posts.getTotalElements(),
                posts.getTotalPages(),
                posts.isFirst(),
                posts.isLast()
        );
    }

    public PageResponse<PostResponse> getOwnPosts(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.findByUser(user, pageable);

        List<PostResponse> postResponses = posts.stream()
                .map(post -> {
                    int likeNumber = likeRepository.countByPostId(post.getId());
                    return PostResponse
                            .mapperToResponse(post, user.getFirstName(), user.getLastName(), user.getAvatarUrl(), likeNumber);
                })
                .collect(Collectors.toList());

        return new PageResponse<>(
                postResponses,
                posts.getNumber(),
                posts.getSize(),
                (int) posts.getTotalElements(),
                posts.getTotalPages(),
                posts.isFirst(),
                posts.isLast()
        );
    }

    public PageResponse<PostResponse> getUserPosts(long userId, int page, int size) {
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", userId));

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.findByUser(user, pageable);

        List<PostResponse> postResponses = posts.stream()
                .map(post -> {
                    int likeNumber = likeRepository.countByPostId(post.getId());
                    return PostResponse
                            .mapperToResponse(post, user.getFirstName(), user.getLastName(), user.getAvatarUrl(), likeNumber);
                })
                .collect(Collectors.toList());

        return new PageResponse<>(
                postResponses,
                posts.getNumber(),
                posts.getSize(),
                (int) posts.getTotalElements(),
                posts.getTotalPages(),
                posts.isFirst(),
                posts.isLast()
        );
    }

    public PageResponse<PostResponse> getPostsByEducationInstitution(long educationInstitutionId, int page, int size) {
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        EducationInstitution educationInstitution = educationInstitutionRepository
                .findById(educationInstitutionId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.EDUCATION_INSTITUTION_NOT_FOUND, "id", educationInstitutionId));

        Page<Post> posts = postRepository.findByEducationInstitution(educationInstitution, pageable);
        List<PostResponse> postResponses = posts.stream()
                .map(post -> {
                    int likeNumber = likeRepository.countByPostId(post.getId());
                    return PostResponse.mapperToResponse(post, post.getUser().getFirstName(),
                            post.getUser().getLastName(), post.getUser().getAvatarUrl(), likeNumber
                    );
                })
                .collect(Collectors.toList());

        return new PageResponse<>(
                postResponses,
                posts.getNumber(),
                posts.getSize(),
                (int) posts.getTotalElements(),
                posts.getTotalPages(),
                posts.isFirst(),
                posts.isLast()
        );
    }
}
