package com.eswap.service;

import com.eswap.common.constants.*;
import com.eswap.common.exception.*;
import com.eswap.model.*;
import com.eswap.repository.*;
import com.eswap.response.AuthenticationResponse;
import com.eswap.response.FollowResponse;
import com.eswap.response.UserResponse;
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
import java.util.List;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final BlockRepository blockRepository;
    private final FollowRepository followRepository;
    private final NotificationService notificationService;
    private final PostRepository postRepository;
    private final UploadService uploadService;


    public AuthenticationResponse getLoginInfo(Authentication auth) {
        User user = (User) auth.getPrincipal();
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
     * @param userEmail
     */
    public void lockedUserByAdmin(Authentication connectedUser, String userEmail) {
        User admin = (User) connectedUser.getPrincipal();

        if (!RoleType.ADMIN.equals(admin.getRole().getName())) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }

        User targetUser = userRepository.findByEmail(userEmail).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "email", userEmail));

        targetUser.setAccountLocked(true);
        userRepository.save(targetUser);
    }

    /**
     * 2. Mở khóa tài khoản
     *
     * @param connectedUser
     * @param userEmail
     */
    public void unLockedUserByAdmin(Authentication connectedUser, String userEmail) {
        User admin = (User) connectedUser.getPrincipal();

        if (!RoleType.ADMIN.equals(admin.getRole().getName())) {
            throw new OperationNotPermittedException(AppErrorCode.AUTH_FORBIDDEN);
        }

        User targetUser = userRepository.findByEmail(userEmail).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "email", userEmail));

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
        user.setEnabled(false);
        userRepository.save(user);
    }

    /**
     * 5. Thiết lập password mới
     */
    public void changePassword(Authentication connectedUser, ChangePasswordRequest request) {
//        User user = (User) connectedUser.getPrincipal();
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
    public User changeInformation(Authentication connectedUser, ChangeInfoRequest request) {
        User user = (User) connectedUser.getPrincipal();
        if (user.isEnabled() && user.isAccountNonLocked()) {
            if (user.getFirstName() != request.getFirstname()) user.setFirstName(request.getFirstname());
            if (user.getLastName() != request.getLastname()) user.setLastName(request.getLastname());
            if (user.getDob() != request.getDob()) user.setDob(request.getDob());
            if (user.getGender() != request.getGender()) user.setGender(request.getGender());
            if (user.getAddress() == null || user.getAddress() != request.getAddress())
                user.setAddress(request.getAddress());
            if (user.getPhoneNumber() == null || user.getPhoneNumber() != request.getPhoneNumber())
                user.setPhoneNumber(request.getPhoneNumber());
            return userRepository.save(user);
        } else {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
    }

    /**
     * 7. Thay đổi email
     */
    public User changeEmail(Authentication connectedUser, ChangeEmailRequest request) {
//        User user = (User) connectedUser.getPrincipal();
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
     * 8. Chặn người khác
     *
     * @param connectedUser
     * @param blockedId
     */
    public void blockUser(Authentication connectedUser, long blockedId) {
        User blocker = (User) connectedUser.getPrincipal();
        User blocked = userRepository.findById(blockedId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", blockedId));

        if (blocker.isEnabled() && blocker.isAccountNonLocked()) {
            if (!blockRepository.existsByBlockerAndBlocked(blocker, blocked)) {
                blockRepository.save(Block.builder().blocker(blocker).blocked(blocked).build());
            }
        }
    }

    /**
     * 9. Bỏ chặn người khác
     *
     * @param connectedUser
     * @param blockedId
     */
    public void unblockUser(Authentication connectedUser, long blockedId) {
        User blocker = (User) connectedUser.getPrincipal();
        User blocked = userRepository.findById(blockedId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", blockedId));

        if (blocker.isEnabled() && blocker.isAccountNonLocked()) {
            if (blockRepository.existsByBlockerAndBlocked(blocker, blocked)) {
                blockRepository.deleteByBlockerAndBlocked(blocker, blocked);
            }
        }
    }

    /**
     * 10. Kiểm tra có chặn người dùng khác
     *
     * @param blockerId
     * @param blockedId
     * @return
     */
    public boolean isBlocked(long blockerId, long blockedId) {
        return blockRepository.existsByBlockerIdAndBlockedId(blockerId, blockedId);
    }

    /**
     * 11. Follow người khác
     */
    public FollowResponse follow(Authentication connectedUser, long followeeUserId) {
        User user = (User) connectedUser.getPrincipal();

        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }

        if (user.getId() == followeeUserId) {
            throw new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", followeeUserId);
        }

        User followeeUser = userRepository.findById(followeeUserId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", followeeUserId));
        Follow follow = followRepository.getByFollowerIdAndFolloweeId(user.getId(), followeeUser.getId());

        FollowStatus followStatus = (follow == null) ? FollowStatus.UNFOLLOWED : (follow.isWaitConfirm() == true) ? FollowStatus.WAITING : FollowStatus.FOLLOWED;
        if (followStatus == FollowStatus.FOLLOWED || followStatus == FollowStatus.WAITING) {
            throw new AlreadyExistsException(AppErrorCode.FOLLOW_USER_FOLLOWED);
        } else {
            Follow newFollow = Follow.builder().follower(user).followee(followeeUser).waitConfirm(followeeUser.isRequireFollowApproval() ? true : false).build();

            newFollow = followRepository.save(newFollow);

            notificationService.createAndPushNotification(newFollow.getFollower().getId(), RecipientType.INDIVIDUAL, NotificationCategory.NEW_FOLLOW, NotificationType.INFORM, newFollow.isWaitConfirm() ? newFollow.getFollower().getFirstName() + " " + newFollow.getFollower().getLastName() + " gửi yêu cầu theo dõi bạn" : newFollow.getFollower().getFirstName() + " " + newFollow.getFollower().getLastName() + " đã theo dõi bạn", "", null, newFollow.getFollowee().getId());

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
    public FollowResponse confirmFollow(Authentication connectedUser, long requestFollowUserId) {
        User user = (User) connectedUser.getPrincipal();

        if (!user.isEnabled() || !user.isAccountNonLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }
        User requestFollowUser = userRepository.findById(requestFollowUserId).orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", requestFollowUserId));

        Follow follow = followRepository.findByFollowerAndFollowee(requestFollowUser, user).orElseThrow(() -> new IllegalStateException("Người này chưa theo dõi bạn mà :))"));

        follow.setWaitConfirm(false);

        followRepository.save(follow);

        return FollowResponse.builder().id(follow.getId()).status(follow.isWaitConfirm() ? FollowStatus.WAITING : FollowStatus.FOLLOWED).build();

    }

    /**
     * 15. enable requireFollowApproval
     */
    public void enableRequireFollowApproval(Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        user.setRequireFollowApproval(true);
        userRepository.save(user);
    }

    /**
     * 16. disable requireFollowApproval
     */
    public void disableRequireFollowApproval(Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        user.setRequireFollowApproval(true);
        userRepository.save(user);
    }

    /**
     * 17. update avt
     */
    public String updateAvatar(Authentication connectedUser, MultipartFile file) {
        User user = (User) connectedUser.getPrincipal();
        String newAvatarUrl = uploadService.upload(file);
        user.setAvatarUrl(newAvatarUrl);
        user.setLastModified(OffsetDateTime.now());
        user = userRepository.save(user);
        return user.getAvatarUrl();
    }

    public void deleteAvatar(Authentication connectedUser) {
        User user = (User) connectedUser.getPrincipal();
        String oldAvatarUrl = user.getAvatarUrl();
        user.setAvatarUrl(null);
        user.setLastModified(OffsetDateTime.now());
        userRepository.save(user);
        uploadService.deleteByUrl(oldAvatarUrl);
    }

    public List<User> getFollowers(long userId) {
        List<User> followser = followRepository.findFollowersByUserId(userId);
        return followser;
    }

    public PageResponse<UserResponse> findUser(Authentication auth, String keyword, int page, int size) {
        User user = (User) auth.getPrincipal();

        Pageable pageable = PageRequest.of(page, size);
        Page<User> users = userRepository.searchUsersWithPriority(user, keyword, pageable);

        List<UserResponse> usersResponse = users.stream().map(u -> {
            FollowStatus followStatus;
            if (u.getId() == user.getId()) {
                followStatus = null;
            } else {
                Follow follow = followRepository.getByFollowerIdAndFolloweeId(user.getId(), u.getId());
                followStatus = (follow == null) ? FollowStatus.UNFOLLOWED : ((follow.isWaitConfirm() == true) ? FollowStatus.WAITING : FollowStatus.FOLLOWED);
            }

            return UserResponse.mapperToUserResponse(u, followStatus, u.getId() == user.getId());
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

        int postCount = postRepository.countPostsByUser(findUser);
        int followerCount = followRepository.countByFollowee(user);
        int followeeCount = followRepository.countByFollower(user);
        UserResponse userResponse = UserResponse.mapperToUserResponse(findUser, followStatus, postCount, followerCount, followeeCount, findUser.getGender(), findUser.getCreatedAt().toString(), findUser.getId() == user.getId());
        return userResponse;
    }

    public PageResponse<UserResponse> getUsersForAdmin(String keyword, int page, int size) {
        Pageable pageable = PageRequest.of(page, size);
        Page<User> users = keyword != null ? userRepository.getUsersWithKeyword(keyword, pageable)
                : userRepository.getUsers(pageable);

        List<UserResponse> usersResponse = users.stream().map(u -> UserResponse.mapperToUserResponse(u, FollowStatus.UNFOLLOWED, false)).collect(Collectors.toList());
        return new PageResponse<>(usersResponse, users.getNumber(), users.getSize(), (int) users.getTotalElements(), users.getTotalPages(), users.isFirst(), users.isLast());
    }
}
