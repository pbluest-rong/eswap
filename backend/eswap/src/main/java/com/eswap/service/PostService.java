package com.eswap.service;

import com.eswap.common.constants.*;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.kafka.post.PostProducer;
import com.eswap.model.*;
import com.eswap.repository.*;
import com.eswap.request.AddPostRequest;
import com.eswap.request.SearchFilterSortRequest;
import com.eswap.response.PostResponse;
import com.eswap.service.upload.UploadService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.hibernate.validator.constraints.LuhnCheck;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.math.BigDecimal;
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
    private final FollowRepository followRepository;
    private final ProvinceRepository provinceRepository;
    private final CategoryService categoryService;

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
        if (user.getEducationInstitution() != null) {
            educationInstitution = educationInstitutionRepository.findById(user.getEducationInstitution().getId())
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
        post.setCondition(request.getCondition());
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
        postProducer.sendPostCreatedEvent(PostResponse.mapperToResponse(post, user.getFirstName(), user.getLastName(), user.getAvatarUrl(), 0, true));
    }

    public PageResponse<PostResponse> getSuggestedPosts(Authentication connectedUser, int page, int size, boolean isOnlyShop, SearchFilterSortRequest searchFilterSortRequest) {
        User user = (User) connectedUser.getPrincipal();
        if (searchFilterSortRequest != null) {
            SortPostType sortBy = (searchFilterSortRequest.getSortBy() != null) ? SortPostType.valueOf(searchFilterSortRequest.getSortBy()) : null;

            Sort sort;
            if (sortBy == null)
                sort = Sort.by(Sort.Direction.DESC, "createdAt");
            else
                switch (sortBy) {
                    case LATEST -> sort = Sort.by(Sort.Direction.DESC, "createdAt");
                    case PRICE_ASC -> sort = Sort.by(Sort.Direction.ASC, "salePrice");
                    case PRICE_DESC -> sort = Sort.by(Sort.Direction.DESC, "salePrice");
                    case RELATED -> {
                        sort = Sort.by(Sort.Direction.DESC, "createdAt");
                    }
                    default -> sort = Sort.by(Sort.Direction.DESC, "createdAt");
                }

            Pageable pageable = PageRequest.of(page, size, sort);
            Condition condition = (searchFilterSortRequest.getCondition() != null) ? Condition.valueOf(searchFilterSortRequest.getCondition()) : null;

            List<Long> expandedCategoryIds = null;
            if (searchFilterSortRequest.getCategoryIdList() != null) {
                expandedCategoryIds = new ArrayList<>(categoryService.getAllCategoryIds(searchFilterSortRequest.getCategoryIdList()));
            }
            Page<Post> posts = postRepository.getSuggestedPosts(
                    user,
                    pageable,
                    searchFilterSortRequest.getKeyword(),
                    expandedCategoryIds,
                    searchFilterSortRequest.getBrandIdList(),
                    searchFilterSortRequest.getMinPrice(),
                    searchFilterSortRequest.getMaxPrice(),
                    condition,
                    isOnlyShop
            );
            return convertPostResponseToPageResponse(user, posts);
        }

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.getSuggestedPosts(user, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    public PageResponse<PostResponse> getOwnPosts(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.getPost(user, pageable);

        List<PostResponse> postResponses = posts.stream()
                .map(post -> {
                    int likeNumber = likeRepository.countByPostId(post.getId());
                    return PostResponse
                            .mapperToResponse(post, user.getFirstName(), user.getLastName(), user.getAvatarUrl(), likeNumber, null);
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

    public PageResponse<PostResponse> getUserPosts(Authentication connectedUser, long userId, int page, int size) {
        User userPrincipal = (User) connectedUser.getPrincipal();
        User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", userId));
        boolean isFollower = (followRepository.existsByFollowerAndFollowee(userPrincipal, user));

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = isFollower ? postRepository.getPost(user, pageable) : postRepository.getPublicPost(user, pageable);

        List<PostResponse> postResponses = posts.stream()
                .map(post -> {
                    int likeNumber = likeRepository.countByPostId(post.getId());
                    boolean isFollowing = followRepository.existsByFollowerIdAndFolloweeId(user.getId(), post.getUser().getId());
                    return PostResponse
                            .mapperToResponse(post, user.getFirstName(), user.getLastName(), user.getAvatarUrl(), likeNumber, isFollowing);
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

    public PageResponse<PostResponse> getPostsByEducationInstitution(Authentication connectedUser, long educationInstitutionId, int page, int size, boolean isOnlyShop,  SearchFilterSortRequest searchFilterSortRequest) {
        User user = (User) connectedUser.getPrincipal();
        EducationInstitution educationInstitution = educationInstitutionRepository
                .findById(educationInstitutionId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.EDUCATION_INSTITUTION_NOT_FOUND, "id", educationInstitutionId));

        if (searchFilterSortRequest != null) {
            SortPostType sortBy = (searchFilterSortRequest.getSortBy() != null) ? SortPostType.valueOf(searchFilterSortRequest.getSortBy()) : null;

            Sort sort;
            if (sortBy == null)
                sort = Sort.by(Sort.Direction.DESC, "createdAt");
            else
                switch (sortBy) {
                    case LATEST -> sort = Sort.by(Sort.Direction.DESC, "createdAt");
                    case PRICE_ASC -> sort = Sort.by(Sort.Direction.ASC, "salePrice");
                    case PRICE_DESC -> sort = Sort.by(Sort.Direction.DESC, "salePrice");
                    case RELATED -> {
                        sort = Sort.by(Sort.Direction.DESC, "createdAt");
                    }
                    default -> sort = Sort.by(Sort.Direction.DESC, "createdAt");
                }

            Pageable pageable = PageRequest.of(page, size, sort);
            Condition condition = (searchFilterSortRequest.getCondition() != null) ? Condition.valueOf(searchFilterSortRequest.getCondition()) : null;
            List<Long> expandedCategoryIds = null;
            if (searchFilterSortRequest.getCategoryIdList() != null) {
                expandedCategoryIds = new ArrayList<>(categoryService.getAllCategoryIds(searchFilterSortRequest.getCategoryIdList()));
            }
            Page<Post> posts = postRepository.findByEducationInstitution(
                    user,
                    educationInstitution,
                    pageable,
                    searchFilterSortRequest.getKeyword(),
                    expandedCategoryIds,
                    searchFilterSortRequest.getBrandIdList(),
                    searchFilterSortRequest.getMinPrice(),
                    searchFilterSortRequest.getMaxPrice(),
                    condition,
                    isOnlyShop
            );
            return convertPostResponseToPageResponse(user, posts);
        }
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.findByEducationInstitution(user, educationInstitution, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    public PageResponse<PostResponse> getPostsByProvince(Authentication connectedUser, String provinceId, int page, int size, boolean isOnlyShop,  SearchFilterSortRequest searchFilterSortRequest) {
        User user = (User) connectedUser.getPrincipal();
        Province province = provinceRepository
                .findById(provinceId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.PROVINCE_NOT_FOUND, "id", provinceId));

        if (searchFilterSortRequest != null) {
            SortPostType sortBy = (searchFilterSortRequest.getSortBy() != null) ? SortPostType.valueOf(searchFilterSortRequest.getSortBy()) : null;

            Sort sort;
            if (sortBy == null)
                sort = Sort.by(Sort.Direction.DESC, "createdAt");
            else
                switch (sortBy) {
                    case LATEST -> sort = Sort.by(Sort.Direction.DESC, "createdAt");
                    case PRICE_ASC -> sort = Sort.by(Sort.Direction.ASC, "salePrice");
                    case PRICE_DESC -> sort = Sort.by(Sort.Direction.DESC, "salePrice");
                    case RELATED -> {
                        sort = Sort.by(Sort.Direction.DESC, "createdAt");
                    }
                    default -> sort = Sort.by(Sort.Direction.DESC, "createdAt");
                }

            Pageable pageable = PageRequest.of(page, size, sort);
            Condition condition = (searchFilterSortRequest.getCondition() != null) ? Condition.valueOf(searchFilterSortRequest.getCondition()) : null;
            List<Long> expandedCategoryIds = null;
            if (searchFilterSortRequest.getCategoryIdList() != null) {
                expandedCategoryIds = new ArrayList<>(categoryService.getAllCategoryIds(searchFilterSortRequest.getCategoryIdList()));
            }
            Page<Post> posts = postRepository.findByProvince(
                    user,
                    province,
                    pageable,
                    searchFilterSortRequest.getKeyword(),
                    expandedCategoryIds,
                    searchFilterSortRequest.getBrandIdList(),
                    searchFilterSortRequest.getMinPrice(),
                    searchFilterSortRequest.getMaxPrice(),
                    condition,
                    isOnlyShop
            );
            return convertPostResponseToPageResponse(user, posts);
        }
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.findByProvince(user, province, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    private PageResponse<PostResponse> convertPostResponseToPageResponse(User user, Page<Post> posts) {
        List<PostResponse> postResponses = posts.stream()
                .map(post -> {
                    int likeNumber = likeRepository.countByPostId(post.getId());
                    boolean isFollowing = followRepository.existsByFollowerIdAndFolloweeId(user.getId(), post.getUser().getId());
                    return PostResponse.mapperToResponse(post, post.getUser().getFirstName(),
                            post.getUser().getLastName(), post.getUser().getAvatarUrl(), likeNumber, isFollowing
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

    public PageResponse<PostResponse> getPostsOfFollowing(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());

        Page<Post> posts = postRepository.findPostsOfFollowing(user, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }
}
