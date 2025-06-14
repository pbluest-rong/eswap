package com.eswap.service;

import com.eswap.common.constants.*;
import com.eswap.common.exception.*;
import com.eswap.common.security.JwtService;
import com.eswap.model.*;
import com.eswap.repository.*;
import com.eswap.response.*;
import com.eswap.request.ChangeEmailRequest;
import com.eswap.request.ChangeInfoRequest;
import com.eswap.request.ChangePasswordRequest;
import com.eswap.service.notification.NotificationService;
import com.eswap.service.upload.UploadService;
import jakarta.transaction.Transactional;
import lombok.RequiredArgsConstructor;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.OffsetDateTime;
import java.util.HashMap;
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final FollowRepository followRepository;
    private final NotificationService notificationService;
    private final PostRepository postRepository;
    private final UploadService uploadService;
    private final EducationInstitutionRepository educationInstitutionRepository;
    private final JwtService jwtService;
    private final NotificationRepository notificationRepository;
    private final MessageRepository messageRepository;
    private final OrderRepository orderRepository;
    private final TransactionRepository transactionRepository;

    public AuthenticationResponse getLoginInfo(Authentication auth) {
        User user = (User) auth.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        String educationInstitutionName = user.getEducationInstitution().getName();
        return AuthenticationResponse.builder()
                .userId(user.getId())
                .role(user.getRole().getName())
                .educationInstitutionId(user.getEducationInstitution().getId()).educationInstitutionName(educationInstitutionName)
                .build();
    }

    /**
     * 1. khóa tài khoản
     *
     * @param connectedUser
     */
    public void lockedUserByAdmin(Authentication connectedUser, long id) {
        User admin = (User) connectedUser.getPrincipal();

        if (!RoleType.ADMIN.equals(admin.getRole().getName())) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }

        User targetUser = userRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", id));
        targetUser.setAccountLocked(true);
        userRepository.save(targetUser);
    }

    /**
     * 2. Mở khóa tài khoản
     */
    public void unLockedUserByAdmin(Authentication connectedUser, long id) {
        User admin = (User) connectedUser.getPrincipal();

        if (!RoleType.ADMIN.equals(admin.getRole().getName())) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }

        User targetUser = userRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", id));

        targetUser.setAccountLocked(false);
        userRepository.save(targetUser);
    }

    /**
     * 3. Hoàn tác vô hiệu hóa tài khoản
     *
     * @param connectedUser
     */
    public void enableAccount(Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        user.setEnabled(true);
        userRepository.save(user);
    }

    /**
     * 4. Vô hiệu hóa tài khoản
     *
     * @param connectedUser
     */
    public void disableAccount(Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        user.setEnabled(false);
        userRepository.save(user);
    }

    /**
     * 5. Thiết lập password mới
     */
    public void changePassword(Authentication connectedUser, ChangePasswordRequest request) {
//        User user = (User) connectedUser.getPrincipal();
//        if (!user.isEnabled() || user.isAccountLocked()) {
//            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
//        }
//        if (user.isEnabled() && user.isAccountNonLocked()) {
//            Optional<OTP> optionalToken = tokenRepository.findByUserEmail(user.getEmail());
//            if (optionalToken.isPresent() &&
//                    optionalToken.get().getExpiresAt().isAfter(LocalDateTime.now()) && request.getCodeToken().equals(optionalToken.get().getOtp())) {
//                user.setPassword(passwordEncoder.encode(request.getNewPassword()));
//                userRepository.save(user);
//            } else {
//                throw new CodeInvalidException(AppErrorCode.AUTH_INVALID_CODE);
//            }
//        } else {
//            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
//        }
    }

    /**
     * 6. Thay đổi thông tin: Tên, ngày sinh, địa chỉ, số điện thoại, giới tính
     */
    public AuthenticationResponse changeInformation(Authentication connectedUser, ChangeInfoRequest request) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        if (user.isEnabled() && user.isAccountNonLocked()) {
            //Username
            if (user.getUsername() != request.getUsername())
                user.setUsername(request.getUsername());
            //Firstname
            if (user.getFirstName() != request.getFirstname())
                user.setFirstName(request.getFirstname());
            //Lastname
            if (user.getLastName() != request.getLastname())
                user.setLastName(request.getLastname());
            //Require follow approval
            if (user.isRequireFollowApproval() != request.isRequireFollowApproval())
                user.setRequireFollowApproval(request.isRequireFollowApproval());
            // education
            if (request.getEducationInstitutionId() != null && user.getEducationInstitution().getId() != request.getEducationInstitutionId()) {
                EducationInstitution newEduIns = educationInstitutionRepository.findById(request.getEducationInstitutionId()).orElseThrow(
                        () -> new ResourceNotFoundException(AppErrorCode.EDUCATION_INSTITUTION_NOT_FOUND, "id", request.getEducationInstitutionId())
                );
                if (user.getEducationInstitution() != newEduIns) {
                    user.setEducationInstitution(newEduIns);
                }
            }
            user = userRepository.save(user);
            var claims = new HashMap<String, Object>();

            var jwtToken = jwtService.generateToken(claims, user);
            var refreshToken = jwtService.generateRefreshToken(user);

            return AuthenticationResponse.builder()
                    .accessToken(jwtToken)
                    .refreshToken(refreshToken)
                    .userId(user.getId())
                    .username(user.getUsername())
                    .avatarUrl(user.getAvatarUrl())
                    .firstName(user.getFirstName())
                    .lastName(user.getLastName())
                    .role(user.getRole().getName())
                    .educationInstitutionId(user.getEducationInstitution().getId())
                    .educationInstitutionName(user.getEducationInstitution().getName())
                    .unreadNotificationNumber(0)
                    .unreadMessageNumber(0)
                    .build();
        } else {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
    }

    /**
     * 7. Thay đổi email
     */
    public User changeEmail(Authentication connectedUser, ChangeEmailRequest request) {
//        User user = (User) connectedUser.getPrincipal();
//        if (!user.isEnabled() || user.isAccountLocked()) {
//            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
//        }
//        if (user.isEnabled() && user.isAccountNonLocked()) {
//            if (user.getEmail() == request.getNewEmail() || userRepository.existsByEmail(request.getNewEmail())) {
//                throw new AlreadyExistsException(AppErrorCode.USER_EXISTS, "email", request.getNewEmail());
//            }
//            Optional<OTP> optionalToken = tokenRepository.findByUserEmail(user.getEmail());
//            if (optionalToken.isPresent() &&
//                    optionalToken.get().getExpiresAt().isAfter(LocalDateTime.now()) && request.getCodeToken().equals(optionalToken.get().getOtp())) {
//                user.setEmail(request.getNewEmail());
//                return userRepository.save(user);
//            } else {
//                throw new CodeInvalidException(AppErrorCode.AUTH_INVALID_CODE);
//            }
//        } else {
        throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
//        }
    }

    /**
     * 11. Follow người khác
     */
    public FollowResponse follow(Authentication connectedUser, long followeeUserId) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }

        if (user.getId() == followeeUserId) {
            throw new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", followeeUserId);
        }

        User followeeUser = userRepository.findById(followeeUserId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", followeeUserId));
        Follow follow = followRepository.getByFollowerIdAndFolloweeId(user.getId(), followeeUser.getId());

        FollowStatus followStatus = (follow == null) ? FollowStatus.UNFOLLOWED : (follow.isWaitConfirm() == true) ? FollowStatus.WAITING : FollowStatus.FOLLOWED;
        if (followStatus == FollowStatus.FOLLOWED) {
            throw new AlreadyExistsException(AppErrorCode.FOLLOW_USER_FOLLOWED);
        } else {
            Follow newFollow = Follow.builder().follower(user).followee(followeeUser).waitConfirm(followeeUser.isRequireFollowApproval() ? true : false).build();

            newFollow = followRepository.save(newFollow);

            notificationService.createAndPushNotification(newFollow.getFollower().getId(), RecipientType.INDIVIDUAL,
                    newFollow.isWaitConfirm() ? NotificationCategory.NEW_REQUEST_FOLLOW : NotificationCategory.NEW_FOLLOW,
                    NotificationType.INFORM,
                    newFollow.isWaitConfirm() ? newFollow.getFollower().getFirstName() + " " + newFollow.getFollower().getLastName() + " gửi yêu cầu theo dõi bạn" : newFollow.getFollower().getFirstName() + " " + newFollow.getFollower().getLastName() + " đã theo dõi bạn", "", null, null, newFollow.getFollowee().getId());

            return FollowResponse.builder().id(newFollow.getId()).status(newFollow.isWaitConfirm() ? FollowStatus.WAITING : FollowStatus.FOLLOWED).build();
        }
    }

    /**
     * 12. Unfollow người khác
     */
    @Transactional
    public void unfollow(Authentication connectedUser, long followeeUserId) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }

        User followeeUser = userRepository.findById(followeeUserId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", followeeUserId));

        Follow follow = followRepository.findByFollowerAndFollowee(user, followeeUser).orElseThrow(() -> new IllegalStateException("Bạn chưa theo dõi người này!"));

        followRepository.delete(follow);
    }

    /**
     * 14. Confirm follow request
     */
    public FollowResponse acceptFollow(Authentication connectedUser, long requestFollowUserId) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        if (!user.isEnabled() || !user.isAccountNonLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        User requestFollowUser = userRepository.findById(requestFollowUserId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", requestFollowUserId));

        Follow follow = followRepository.findByFollowerAndFollowee(requestFollowUser, user).orElseThrow(() -> new IllegalStateException("Người này chưa theo dõi bạn mà :))"));

        if (follow.isWaitConfirm()) {
            follow.setWaitConfirm(false);
            followRepository.save(follow);
        }

        return FollowResponse.builder().id(follow.getId()).status(follow.isWaitConfirm() ? FollowStatus.WAITING : FollowStatus.FOLLOWED).build();

    }

    /**
     * 15. enable requireFollowApproval
     */
    public void enableRequireFollowApproval(Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        user.setRequireFollowApproval(true);
        userRepository.save(user);
    }

    /**
     * 16. disable requireFollowApproval
     */
    public void disableRequireFollowApproval(Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        user.setRequireFollowApproval(true);
        userRepository.save(user);
    }


    public void removeFollow(Authentication connectedUser, long followerUserId) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }

        User followerUser = userRepository.findById(followerUserId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", followerUserId));

        Follow follow = followRepository.findByFollowerAndFollowee(followerUser, user).orElseThrow(() -> new IllegalStateException("Người này không theo dõi bạn!"));

        followRepository.delete(follow);
    }

    /**
     * 17. update avt
     */
    public String updateAvatar(Authentication connectedUser, MultipartFile file) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        String newAvatarUrl = uploadService.upload(file);
        user.setAvatarUrl(newAvatarUrl);
        user.setLastModified(OffsetDateTime.now());
        user = userRepository.save(user);
        return user.getAvatarUrl();
    }

    public void deleteAvatar(Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        String oldAvatarUrl = user.getAvatarUrl();
        if (oldAvatarUrl != null) {
            user.setAvatarUrl(null);
            user.setLastModified(OffsetDateTime.now());
            userRepository.save(user);
            uploadService.deleteByUrl(oldAvatarUrl);
        }
    }

    public List<User> getFollowers(long userId) {
        List<User> followser = followRepository.findFollowersByUserId(userId);
        return followser;
    }

    public PageResponse<UserResponse> findUser(Authentication auth, String keyword, Boolean isGetFollowersOrFollowing, int page, int size) {
        User user = (User) auth.getPrincipal();
        Pageable pageable = PageRequest.of(page, size);
        Page<User> users = userRepository.searchUsersWithPriority(user, keyword, isGetFollowersOrFollowing, pageable);

        List<UserResponse> usersResponse = users.stream().map(u -> {
            FollowStatus followStatus;
            if (u.getId() == user.getId()) {
                followStatus = null;
            } else {
                Follow follow = followRepository.getByFollowerIdAndFolloweeId(user.getId(), u.getId());
                followStatus = (follow == null) ? FollowStatus.UNFOLLOWED : ((follow.isWaitConfirm() == true) ? FollowStatus.WAITING : FollowStatus.FOLLOWED);
            }

            Follow followMe = followRepository.getByFollowerIdAndFolloweeId(u.getId(), user.getId());
            boolean waitingAcceptFollow = followMe != null && followMe.isWaitConfirm();

            return UserResponse.mapperToUserResponse(u, followStatus, u.getId() == user.getId(), waitingAcceptFollow);
        }).collect(Collectors.toList());
        return new PageResponse<>(usersResponse, users.getNumber(), users.getSize(), (int) users.getTotalElements(), users.getTotalPages(), users.isFirst(), users.isLast());

    }

    public UserResponse getUserById(long id, Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        User findUser = userRepository.findById(id).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", id));
        FollowStatus followStatus;
        if (id == user.getId()) {
            followStatus = null;
        } else {
            Follow follow = followRepository.getByFollowerIdAndFolloweeId(user.getId(), findUser.getId());
            followStatus = (follow == null) ? FollowStatus.UNFOLLOWED : ((follow.isWaitConfirm() == true) ? FollowStatus.WAITING : FollowStatus.FOLLOWED);
        }
        Follow followMe = followRepository.getByFollowerIdAndFolloweeId(findUser.getId(), user.getId());
        boolean waitingAcceptFollow = followMe != null && followMe.isWaitConfirm();

        int postCount = postRepository.countPostsByUser(findUser);
        int followerCount = followRepository.countFollower(findUser);
        int followeeCount = followRepository.countFollowee(findUser);

        UserResponse userResponse = UserResponse.mapperToUserResponse(findUser, followStatus, postCount, followerCount, followeeCount, findUser.getGender(),
                findUser.getCreatedAt().toString(), findUser.getId() == user.getId(), waitingAcceptFollow);
        return userResponse;
    }

    public PageResponse<UserResponse> getUsersForAdmin(Authentication auth, String keyword, int page, int size) {
        User user = (User) auth.getPrincipal();

        Pageable pageable = PageRequest.of(page, size);
        Page<User> users = userRepository.searchUsersWithPriority(user, keyword, null, pageable);

        List<UserResponse> usersResponse = users.stream().map(u -> UserResponse.mapperToUserResponse(u, null, u.getId() == user.getId(), false)).collect(Collectors.toList());
        return new PageResponse<>(usersResponse, users.getNumber(), users.getSize(), (int) users.getTotalElements(), users.getTotalPages(), users.isFirst(), users.isLast());
    }

    public UserResponse changeUsername(Authentication auth, String username) {
        boolean isUsernameExists = userRepository.existsByUsername(username);
        if (isUsernameExists) {
            throw new AlreadyExistsException(AppErrorCode.USER_EXISTS, "username", username);
        }
        User user = (User) auth.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        user.setUsername(username);
        user.setLastModified(OffsetDateTime.now());
        user = userRepository.save(user);
        return UserResponse.mapperToUserResponse(user, null, true, false);
    }

    public UserResponse changeName(Authentication auth, String firstName, String lastName) {
        User user = (User) auth.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        user.setFirstName(firstName);
        user.setLastName(lastName);
        user.setLastModified(OffsetDateTime.now());
        user = userRepository.save(user);
        return UserResponse.mapperToUserResponse(user, null, true, false);
    }

    public UserResponse changeEducationInstitution(Authentication auth, long educationInstitutionId) {
        EducationInstitution eduInstitution = educationInstitutionRepository.findById(educationInstitutionId).orElseThrow(() -> new IllegalArgumentException("EDUCATION INSTITUTION ID was not initialized"));
        User user = (User) auth.getPrincipal();
        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        user.setEducationInstitution(eduInstitution);
        user.setLastModified(OffsetDateTime.now());
        user = userRepository.save(user);
        return UserResponse.mapperToUserResponse(user, null, true, false);
    }

    public DashboardResponse dashboard() {
        long totalUsers = userRepository.count();
        long totalPosts = postRepository.count();
        long totalOrders = orderRepository.count();
        long totalTransactions = transactionRepository.count();
        return new DashboardResponse(totalUsers, totalPosts, totalOrders, totalTransactions);
    }
}
