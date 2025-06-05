package com.eswap.service;

import com.eswap.common.constants.*;
import com.eswap.common.exception.AlreadyExistsException;
import com.eswap.common.exception.ResourceNotFoundException;
import com.eswap.kafka.post.PostProducer;
import com.eswap.model.*;
import com.eswap.repository.*;
import com.eswap.request.AddPostRequest;
import com.eswap.request.SearchFilterSortRequest;
import com.eswap.response.LikePostResponse;
import com.eswap.response.PostResponse;
import com.eswap.service.notification.NotificationService;
import com.eswap.service.upload.UploadService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.data.domain.Sort;
import org.springframework.scheduling.annotation.Async;
import org.springframework.security.core.Authentication;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class PostService {
    private final PostRepository postRepository;
    private final EducationInstitutionRepository educationInstitutionRepository;
    private final CategoryRepository categoryRepository;
    private final BrandRepository brandRepository;
    private final UploadService uploadService;
    private final PostProducer postProducer;
    private final LikeRepository likeRepository;
    private final UserRepository userRepository;
    private final FollowRepository followRepository;
    private final ProvinceRepository provinceRepository;
    private final CategoryService categoryService;
    private final NotificationService notificationService;
    private final RecentSearchesRepository recentSearchesRepository;

    @Transactional
    public void addPost(Authentication connectedUser, AddPostRequest request, MultipartFile[] mediaFiles) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }

        // Lấy entity liên quan từ database
        Category category = categoryRepository.findById(request.getCategoryId()).orElseThrow(() -> new IllegalArgumentException("Category not found"));

        Brand brand = (request.getBrandId() != null) ? brandRepository.findById(request.getBrandId()).orElseThrow(() -> new IllegalArgumentException("Brand not found")) : null;

        EducationInstitution educationInstitution = null;
        if (user.getEducationInstitution() != null) {
            educationInstitution = educationInstitutionRepository.findById(user.getEducationInstitution().getId()).orElseThrow(() -> new IllegalArgumentException("Education Institution not found"));
        }

        Post post = new Post();
        if (request.getStoreId() != null) {
            User store = userRepository.findById(request.getStoreId()).orElseThrow(() -> new IllegalArgumentException("Store not found"));
            post.setName(request.getName());
            post.setDescription(request.getDescription());
            post.setUser(store);
            post.setCategory(category);
            post.setBrand(brand);
            post.setEducationInstitution(educationInstitution);
            post.setOriginalPrice(request.getOriginalPrice());
            post.setSalePrice(request.getSalePrice());
            post.setQuantity(request.getQuantity());
            post.setStatus(PostStatus.PENDING);
            post.setPrivacy(request.getPrivacy());
            post.setCondition(request.getCondition());
            post.setAddress(request.getAddress());
            post.setPhoneNumber(request.getPhoneNumber());
            post.setStoreCustomer(user);
        } else {
            post.setName(request.getName());
            post.setDescription(request.getDescription());
            post.setUser(user);
            post.setCategory(category);
            post.setBrand(brand);
            post.setEducationInstitution(educationInstitution);
            post.setOriginalPrice(request.getOriginalPrice());
            post.setSalePrice(request.getSalePrice());
            post.setQuantity(request.getQuantity());
            post.setStatus(PostStatus.PUBLISHED);
            post.setPrivacy(request.getPrivacy());
            post.setCondition(request.getCondition());
            post.setAddress(request.getAddress());
            post.setPhoneNumber(request.getPhoneNumber());
        }
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
        if (request.getStoreId() != null) {
            notificationService.createAndPushNotification(
                    post.getUser().getId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.NEW_NOTICE,
                    NotificationType.INFORM,
                    "Yêu cầu bán hàng cho store",
                    post.getStoreCustomer().getFirstName() + " " + post.getStoreCustomer().getLastName() + " yêu cầu bán hàng",
                    post.getId(), null,
                    post.getUser().getId()
            );
        } else {
            postProducer.sendPostCreatedEvent(PostResponse.mapperToResponse(post,
                    user.getFirstName(), user.getLastName(), user.getAvatarUrl(),
                    0, false, FollowStatus.FOLLOWED, false));
        }
    }

    public PageResponse<PostResponse> getSuggestedPosts(Authentication connectedUser, int page, int size, boolean isOnlyShop, SearchFilterSortRequest searchFilterSortRequest) {
        User user = (User) connectedUser.getPrincipal();
        if (searchFilterSortRequest != null) {
            SortPostType sortBy = (searchFilterSortRequest.getSortBy() != null) ? SortPostType.valueOf(searchFilterSortRequest.getSortBy()) : null;

            Sort sort;
            if (sortBy == null) sort = Sort.by(Sort.Direction.DESC, "createdAt");
            else switch (sortBy) {
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

            if (searchFilterSortRequest.getKeyword() != null && !searchFilterSortRequest.getKeyword().isEmpty()) {
                saveRecentSearchWord(user.getId(), searchFilterSortRequest.getKeyword());
            }

            Page<Post> posts = postRepository.getSuggestedPosts(user, pageable, searchFilterSortRequest.getKeyword(), expandedCategoryIds, searchFilterSortRequest.getBrandIdList(), searchFilterSortRequest.getMinPrice(), searchFilterSortRequest.getMaxPrice(), condition, isOnlyShop);
            return convertPostResponseToPageResponse(user, posts);
        }

        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.getSuggestedPosts(user, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    public PageResponse<PostResponse> getPostsForHome(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.findByFollowingOrEducationInstitution(user, user.getEducationInstitution(), pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    public PageResponse<PostResponse> getShowingPosts(Authentication connectedUser, long userId, int page, int size) {
        User userPrincipal = (User) connectedUser.getPrincipal();
        User user = userRepository.findById(userId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", userId));
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.getShowingPosts(userPrincipal, user, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    public PageResponse<PostResponse> getSoldUserPosts(Authentication connectedUser, long userId, int page, int size) {
        User userPrincipal = (User) connectedUser.getPrincipal();
        User user = userRepository.findById(userId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", userId));
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.getSoldPosts(userPrincipal, user, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    public PageResponse<PostResponse> getRecommendUserPosts(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        RecentSearches recentWordSearch = recentSearchesRepository.findByUserId(user.getId()).orElse(null);
        Page<Post> posts;
        if (recentWordSearch != null) {
            posts = postRepository.getRecommendUserPosts(user,
                    recentWordSearch.getWord1(),
                    recentWordSearch.getWord2(),
                    recentWordSearch.getWord3(),
                    recentWordSearch.getWord4(),
                    recentWordSearch.getWord5(),
                    pageable);
        } else {
            posts = postRepository.getSuggestedPosts(user, pageable);
        }
        return convertPostResponseToPageResponse(user, posts);
    }

    public PageResponse<PostResponse> getPostsByEducationInstitution(Authentication connectedUser, long educationInstitutionId, int page, int size, boolean isOnlyShop, SearchFilterSortRequest searchFilterSortRequest) {
        User user = (User) connectedUser.getPrincipal();
        EducationInstitution educationInstitution = educationInstitutionRepository.findById(educationInstitutionId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.EDUCATION_INSTITUTION_NOT_FOUND, "id", educationInstitutionId));

        if (searchFilterSortRequest != null) {
            SortPostType sortBy = (searchFilterSortRequest.getSortBy() != null) ? SortPostType.valueOf(searchFilterSortRequest.getSortBy()) : null;

            Sort sort;
            if (sortBy == null) sort = Sort.by(Sort.Direction.DESC, "createdAt");
            else switch (sortBy) {
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

            if (searchFilterSortRequest.getKeyword() != null && !searchFilterSortRequest.getKeyword().isEmpty()) {
                saveRecentSearchWord(user.getId(), searchFilterSortRequest.getKeyword());
            }

            Page<Post> posts = postRepository.findByEducationInstitution(user, educationInstitution, pageable, searchFilterSortRequest.getKeyword(), expandedCategoryIds, searchFilterSortRequest.getBrandIdList(), searchFilterSortRequest.getMinPrice(), searchFilterSortRequest.getMaxPrice(), condition, isOnlyShop);
            return convertPostResponseToPageResponse(user, posts);
        }
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.findByEducationInstitution(user, educationInstitution, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    public PageResponse<PostResponse> getPostsByProvince(Authentication connectedUser, String provinceId, int page, int size, boolean isOnlyShop, SearchFilterSortRequest searchFilterSortRequest) {
        User user = (User) connectedUser.getPrincipal();
        Province province = provinceRepository.findById(provinceId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.PROVINCE_NOT_FOUND, "id", provinceId));

        if (searchFilterSortRequest != null) {
            SortPostType sortBy = (searchFilterSortRequest.getSortBy() != null) ? SortPostType.valueOf(searchFilterSortRequest.getSortBy()) : null;

            Sort sort;
            if (sortBy == null) sort = Sort.by(Sort.Direction.DESC, "createdAt");
            else switch (sortBy) {
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

            if (searchFilterSortRequest.getKeyword() != null && !searchFilterSortRequest.getKeyword().isEmpty()) {
                saveRecentSearchWord(user.getId(), searchFilterSortRequest.getKeyword());
            }

            Page<Post> posts = postRepository.findByProvince(user, province, pageable, searchFilterSortRequest.getKeyword(), expandedCategoryIds, searchFilterSortRequest.getBrandIdList(), searchFilterSortRequest.getMinPrice(), searchFilterSortRequest.getMaxPrice(), condition, isOnlyShop);
            return convertPostResponseToPageResponse(user, posts);
        }
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.findByProvince(user, province, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    private PageResponse<PostResponse> convertPostResponseToPageResponse(User user, Page<Post> posts) {
        List<PostResponse> postResponses = posts.stream().map(post -> {
            int likeNumber = likeRepository.countByPostId(post.getId());
            boolean liked = likeRepository.existsByPostIdAndUserId(post.getId(), user.getId());
            FollowStatus followStatus;
            if (post.getUser().getId() == user.getId()) {
                followStatus = null;
            } else {
                Follow follow = followRepository.getByFollowerIdAndFolloweeId(user.getId(), post.getUser().getId());
                followStatus = (follow == null) ? FollowStatus.UNFOLLOWED : (follow.isWaitConfirm() == true) ? FollowStatus.WAITING : FollowStatus.FOLLOWED;
            }
            Follow followMe = followRepository.getByFollowerIdAndFolloweeId(post.getUser().getId(), user.getId());
            boolean waitingAcceptFollow = followMe != null && followMe.isWaitConfirm();
            return PostResponse.mapperToResponse(post, post.getUser().getFirstName(), post.getUser().getLastName(), post.getUser().getAvatarUrl(), likeNumber, liked, followStatus, waitingAcceptFollow);
        }).collect(Collectors.toList());

        return new PageResponse<>(
                postResponses,
                posts.getNumber(),
                posts.getSize(),
                (int) posts.getTotalElements(),
                posts.getTotalPages(), posts.isFirst(),
                posts.isLast());
    }

    private PageResponse<PostResponse> convertPostResponseToPageResponseForCustomer(User user, Page<Post> posts) {
        List<PostResponse> postResponses = posts.stream().map(post -> {
            int likeNumber = likeRepository.countByPostId(post.getId());
            boolean liked = likeRepository.existsByPostIdAndUserId(post.getId(), user.getId());
            FollowStatus followStatus;
            if (post.getUser().getId() == user.getId()) {
                followStatus = null;
            } else {
                Follow follow = followRepository.getByFollowerIdAndFolloweeId(user.getId(), post.getUser().getId());
                followStatus = (follow == null) ? FollowStatus.UNFOLLOWED : (follow.isWaitConfirm() == true) ? FollowStatus.WAITING : FollowStatus.FOLLOWED;
            }
            Follow followMe = followRepository.getByFollowerIdAndFolloweeId(post.getUser().getId(), user.getId());
            boolean waitingAcceptFollow = followMe != null && followMe.isWaitConfirm();
            PostResponse response = PostResponse.mapperToResponse(post, post.getUser().getFirstName(), post.getUser().getLastName(), post.getUser().getAvatarUrl(), likeNumber, liked, followStatus, waitingAcceptFollow);

            User customer = post.getStoreCustomer();
            if (customer != null) {
                response.setCustomerId(customer.getId());
                response.setCustomerFirstname(customer.getFirstName());
                response.setCustomerLastname(customer.getLastName());
                response.setCustomerAvtUrl(customer.getAvatarUrl());
            }
            return response;
        }).collect(Collectors.toList());

        return new PageResponse<>(
                postResponses,
                posts.getNumber(),
                posts.getSize(),
                (int) posts.getTotalElements(),
                posts.getTotalPages(), posts.isFirst(),
                posts.isLast());
    }

    public PageResponse<PostResponse> getPostsOfFollowing(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());

        Page<Post> posts = postRepository.findPostsOfFollowing(user, pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    public LikePostResponse likePost(long postId, Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();

        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }

        Post post = postRepository.findById(postId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.POST_NOT_FOUND, postId));
        boolean isLike = likeRepository.existsByPostIdAndUserId(post.getId(), user.getId());
        if (isLike) throw new AlreadyExistsException(AppErrorCode.LIKE_POST_EXISTS);

        Like like = new Like(post, user);
        likeRepository.save(like);

        if (user.getId() != post.getUser().getId())
            notificationService.createAndPushNotification(
                    user.getId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.NEW_LIKE,
                    NotificationType.INFORM,
                    user.getFirstName() + " " + user.getLastName() + " đã like bài đăng của bạn",
                    "Người dùng " + user.getFirstName() + " " + user.getLastName() + " đã like bài đăng của bạn",
                    post.getId(), null,
                    post.getUser().getId()
            );
        int likesCount = likeRepository.countByPostId(postId);
        return new LikePostResponse(like.getPost().getId(), true, likesCount);
    }

    public LikePostResponse unlikePost(long postId, Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        Post post = postRepository.findById(postId).orElseThrow(() -> new ResourceNotFoundException(
                AppErrorCode.POST_NOT_FOUND, postId));
        Like like = likeRepository.findByPostAndUser(post, user).orElseThrow(
                () -> new ResourceNotFoundException(AppErrorCode.LIKE_NOT_FOUND)
        );

        likeRepository.delete(like);

        int likesCount = likeRepository.countByPostId(postId);
        return new LikePostResponse(like.getPost().getId(), false, likesCount);
    }

    public PostResponse getPostById(Authentication connectedUser, long postId) {
        User user = (User) connectedUser.getPrincipal();
        Post post = postRepository.findByIdAndConnectedUser(postId, user).orElseThrow(() -> new ResourceNotFoundException(
                AppErrorCode.POST_NOT_FOUND, postId));
        int likeNumber = likeRepository.countByPostId(post.getId());
        boolean liked = likeRepository.existsByPostIdAndUserId(post.getId(), user.getId());

        FollowStatus followStatus;
        if (post.getUser().getId() == user.getId()) {
            followStatus = null;
        } else {
            Follow follow = followRepository.getByFollowerIdAndFolloweeId(user.getId(), post.getUser().getId());
            followStatus = (follow == null) ? FollowStatus.UNFOLLOWED : (follow.isWaitConfirm() == true) ? FollowStatus.WAITING : FollowStatus.FOLLOWED;
        }
        Follow followMe = followRepository.getByFollowerIdAndFolloweeId(post.getUser().getId(), user.getId());
        boolean waitingAcceptFollow = followMe != null && followMe.isWaitConfirm();
        PostResponse response = PostResponse.mapperToResponse(post, post.getUser().getFirstName(), post.getUser().getLastName(), post.getUser().getAvatarUrl(), likeNumber, liked, followStatus, waitingAcceptFollow);

        User customer = post.getStoreCustomer();
        if (customer != null) {
            response.setCustomerId(customer.getId());
            response.setCustomerFirstname(customer.getFirstName());
            response.setCustomerLastname(customer.getLastName());
            response.setCustomerAvtUrl(customer.getAvatarUrl());
        }
        return response;
    }


    @Async
    public void saveRecentSearchWord(long userId, String word) {
        if (word == null || word.trim().isEmpty()) {
            return; // Don't save empty/null words
        }

        try {
            RecentSearches recentSearches = recentSearchesRepository.findByUserId(userId)
                    .orElseGet(() -> {
                        RecentSearches newSearch = new RecentSearches();
                        newSearch.setUserId(userId);
                        return newSearch;
                    });

            // Shift all words down one position
            String currentWord1 = recentSearches.getWord1();
            String currentWord2 = recentSearches.getWord2();
            String currentWord3 = recentSearches.getWord3();
            String currentWord4 = recentSearches.getWord4();

            // Set new word at position 1
            recentSearches.setWord1(word);

            // Shift previous words down
            recentSearches.setWord2(currentWord1);
            recentSearches.setWord3(currentWord2);
            recentSearches.setWord4(currentWord3);
            recentSearches.setWord5(currentWord4);

            // Don't keep duplicate words in the history
            if (word.equals(currentWord1)) {
                recentSearches.setWord2(currentWord2);
                recentSearches.setWord3(currentWord3);
                recentSearches.setWord4(currentWord4);
                recentSearches.setWord5(null);
            }

            recentSearchesRepository.save(recentSearches);
        } catch (Exception e) {
            log.error("Failed to save recent search word for user {}: {}", userId, e.getMessage());
        }
    }

    public PageResponse<PostResponse> getStorePostsForCustomer(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.getStorePostsForCustomer(user.getId(), pageable);
        return convertPostResponseToPageResponse(user, posts);
    }

    public PageResponse<PostResponse> getPendingPosts(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.getPendingPosts(user, pageable);
        return convertPostResponseToPageResponseForCustomer(user, posts);
    }

    public PageResponse<PostResponse> getAcceptedPosts(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.getAcceptedPosts(user, pageable);
        return convertPostResponseToPageResponseForCustomer(user, posts);
    }

    public PageResponse<PostResponse> getRejectedPosts(Authentication connectedUser, int page, int size) {
        User user = (User) connectedUser.getPrincipal();
        Pageable pageable = PageRequest.of(page, size, Sort.by("createdAt").descending());
        Page<Post> posts = postRepository.getRejectedPosts(user, pageable);
        return convertPostResponseToPageResponseForCustomer(user, posts);
    }

    public void acceptPost(long postId, Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        System.out.println(postId + "-" + user.getId());
        Post post = postRepository.findPendingPostByIdAndStore(postId, user).orElseThrow(() -> new ResourceNotFoundException(
                AppErrorCode.POST_NOT_FOUND, postId));
        System.out.println(postRepository.findById(postId).isEmpty());
        post.setStatus(PostStatus.PUBLISHED);
        post = postRepository.save(post);

        User customer = post.getStoreCustomer();
        // Thông báo với khách hàng
        if (customer != null) {
            notificationService.createAndPushNotification(
                    post.getUser().getId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.NEW_POST_FOLLOWER,
                    NotificationType.INFORM,
                    "Store đã xác nhận yêu cầu bán hàng của bạn",
                    post.getUser().getFirstName() + " " + post.getUser().getLastName() + " đã chấp nhận yêu cầu bán hàng của bạn.",
                    post.getId(), null,
                    customer.getId()
            );
        }
    }


    public void rejectPost(long postId, Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        Post post = postRepository.findPendingPostByIdAndStore(postId, user).orElseThrow(() -> new ResourceNotFoundException(
                AppErrorCode.POST_NOT_FOUND, postId));
        post.setStatus(PostStatus.REJECTED);
        post = postRepository.save(post);

        // Thông báo với khách hàng
        User customer = post.getStoreCustomer();
        if (customer != null) {
            notificationService.createAndPushNotification(
                    post.getUser().getId(),
                    RecipientType.INDIVIDUAL,
                    NotificationCategory.NEW_POST_FOLLOWER,
                    NotificationType.INFORM,
                    "Store đã từ chối yêu cầu bán hàng của bạn",
                    post.getUser().getFirstName() + " " + post.getUser().getLastName() + " đã từ chối yêu cầu bán hàng của bạn.",
                    post.getId(), null,
                    customer.getId()
            );
        }
    }

    public void removePost(long postId, Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        Post post = postRepository.findByIdAndConnectedUser(postId, user).orElseThrow(() -> new ResourceNotFoundException(
                AppErrorCode.POST_NOT_FOUND, postId));
        post.setStatus(PostStatus.DELETED);
        postRepository.save(post);
    }
}
