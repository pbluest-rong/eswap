package com.eswap.response;

import com.eswap.common.constants.FollowStatus;
import com.eswap.model.User;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {
    private long id;
    private String username;
    private String firstname;
    private String lastname;
    private String avatarUrl;
    private String educationInstitutionName;
    private FollowStatus followStatus;
    private Integer postCount;
    private Integer followerCount;

    private Integer followingCount;
    private Boolean gender;
    private String createdAt;
    private boolean isConnectedUser;
    private int reputationScore;
    private String address;
    private String role;
    private boolean isLocked;
    private boolean waitingAcceptFollow;

    public static UserResponse mapperToUserResponse(User user, FollowStatus followStatus, boolean isConnectedUser, boolean waitingAcceptFollow) {
        return new UserResponse(user.getId(), user.getUsername(), user.getFirstName(), user.getLastName(), user.getAvatarUrl(),
                user.getEducationInstitution().getName(), followStatus,
                null, null, null, null, null, isConnectedUser, user.getReputationScore(), user.getAddress(), user.getRole().getName(), user.isAccountLocked(), waitingAcceptFollow);
    }

    public static UserResponse mapperToUserResponse(User user, FollowStatus followtSatus, Integer postCount, Integer followerCount, Integer followingCount, Boolean gender, String createdAt, boolean isConnectedUser, boolean waitingAcceptFollow) {
        return new UserResponse(user.getId(), user.getUsername(), user.getFirstName(), user.getLastName(), user.getAvatarUrl(), user.getEducationInstitution().getName(), followtSatus,
                postCount, followerCount, followingCount, gender, createdAt, isConnectedUser, user.getReputationScore(), user.getAddress(), user.getRole().getName(), user.isAccountLocked(), waitingAcceptFollow);
    }
}
