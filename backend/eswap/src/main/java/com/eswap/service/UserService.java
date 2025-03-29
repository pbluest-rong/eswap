package com.eswap.service;

import com.eswap.common.constants.AppErrorCode;
import com.eswap.common.constants.RoleType;
import com.eswap.common.exception.*;
import com.eswap.model.*;
import com.eswap.repository.BlockRepository;
import com.eswap.repository.OTPRepository;
import com.eswap.repository.FollowRepository;
import com.eswap.response.FollowResponse;
import com.eswap.response.SimpleUserDTO;
import com.eswap.request.ChangeEmailRequest;
import com.eswap.request.ChangeInfoRequest;
import com.eswap.request.ChangePasswordRequest;
import com.eswap.repository.UserRepository;
import com.eswap.service.upload.UploadService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.core.Authentication;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
public class UserService {
    private final UserRepository userRepository;
    private final OTPRepository tokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final BlockRepository blockRepository;
    private final FollowRepository followRepository;
    private final UploadService uploadService;
//    Authentication authentication = SecurityContextHolder.getContext().getAuthentication();

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

        User targetUser = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "email", userEmail));

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

        User targetUser = userRepository.findByEmail(userEmail)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "email", userEmail));

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
            if (user.getFirstName() != request.getFirstname())
                user.setFirstName(request.getFirstname());
            if (user.getLastName() != request.getLastname())
                user.setLastName(request.getLastname());
            if (user.getDob() != request.getDob())
                user.setDob(request.getDob());
            if (user.getGender() != request.getGender())
                user.setGender(request.getGender());
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

        User followeeUser = userRepository.findById(followeeUserId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", followeeUserId));

        Follow follow = Follow.builder()
                .follower(user)
                .followee(followeeUser)
                .waitConfirm(followeeUser.isRequireFollowApproval() ? true : false)
                .build();

        followRepository.save(follow);

        return FollowResponse.builder()
                .id(follow.getId())
                .follower(SimpleUserDTO.builder()
                        .id(user.getId())
                        .username(user.getUsername())
                        .firstname(user.getFirstName())
                        .lastname(user.getLastName())
                        .avatarUrl(user.getAvatarUrl())
                        .build())
                .followee(SimpleUserDTO.builder()
                        .id(followeeUser.getId())
                        .username(followeeUser.getUsername())
                        .firstname(followeeUser.getFirstName())
                        .lastname(followeeUser.getLastName())
                        .avatarUrl(followeeUser.getAvatarUrl())
                        .build())
                .build();
    }

    /**
     * 12. Unfollow người khác
     */
    public void unfollow(Authentication connectedUser, long followeeUserId) {
        User user = (User) connectedUser.getPrincipal();

        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }

        User followeeUser = userRepository.findById(followeeUserId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", followeeUserId));

        Follow follow = followRepository.findByFollowerAndFollowee(user, followeeUser)
                .orElseThrow(() -> new IllegalStateException("Bạn chưa theo dõi người này!"));

        followRepository.delete(follow);
    }

    /**
     * 13. Remove follower
     */
    public void removeFollower(Authentication connectedUser, long followerUserId) {
        User user = (User) connectedUser.getPrincipal();

        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }

        User followerUser = userRepository.findById(followerUserId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", followerUserId));

        Follow follow = followRepository.findByFollowerAndFollowee(followerUser, user)
                .orElseThrow(() -> new IllegalStateException("Người này chưa theo dõi bạn mà :))"));

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
        User requestFollowUser = userRepository.findById(requestFollowUserId)
                .orElseThrow(() -> new ResourceNotFoundException(AppErrorCode.USER_NOT_FOUND, "id", requestFollowUserId));

        Follow follow = followRepository.findByFollowerAndFollowee(requestFollowUser, user)
                .orElseThrow(() -> new IllegalStateException("Người này chưa theo dõi bạn mà :))"));
        follow.setWaitConfirm(false);

        followRepository.save(follow);

        return FollowResponse.builder()
                .id(follow.getId())
                .follower(SimpleUserDTO.builder()
                        .id(requestFollowUser.getId())
                        .username(requestFollowUser.getUsername())
                        .firstname(requestFollowUser.getFirstName())
                        .lastname(requestFollowUser.getFirstName())
                        .avatarUrl(requestFollowUser.getAvatarUrl())
                        .build())
                .followee(SimpleUserDTO.builder()
                        .id(user.getId())
                        .username(user.getUsername())
                        .firstname(user.getFirstName())
                        .lastname(user.getLastName())
                        .avatarUrl(user.getAvatarUrl())
                        .build())
                .build();

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
    public void updateAvatar(Authentication connectedUser, MultipartFile file) {
        if (file == null || file.isEmpty()) {
            throw new IllegalArgumentException("File không được để trống.");
        }

        String contentType = file.getContentType();
        if (contentType == null || !contentType.startsWith("image/")) {
            throw new IllegalArgumentException("Chỉ chấp nhận file ảnh.");
        }
        User user = (User) connectedUser.getPrincipal();

        if (!user.isEnabled() || user.isAccountLocked()) {
            throw new IllegalStateException("Tài khoản này đã vô hiệu hóa hoặc bị khóa!");
        }

        String oldAvt = user.getAvatarUrl();
        String avtUrl = uploadService.upload(file);
        user.setAvatarUrl(avtUrl);
        uploadService.deleteByUrl(oldAvt);
    }

    public List<User> getFollowers(long userId) {
        List<User> followser = followRepository.findFollowersByUserId(userId);
        return followser;
    }
}
