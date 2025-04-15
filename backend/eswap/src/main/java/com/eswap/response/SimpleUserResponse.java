package com.eswap.response;

import com.eswap.model.User;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
public class SimpleUserResponse {
    private long id;
    private String username;
    private String firstname;
    private String lastname;
    private String avatarUrl;
    private String educationInstitutionName;
    private Boolean isFollowing;

    public static SimpleUserResponse mapperToSimpleUserResponse(User user, Boolean isFollowing) {
        return new SimpleUserResponse(user.getId(), user.getUsername(), user.getFirstName(), user.getLastName(), user.getAvatarUrl(), user.getEducationInstitution().getName(), isFollowing);
    }

    public static SimpleUserResponse mapperToSimpleUserResponse(User user) {
        return new SimpleUserResponse(user.getId(), user.getUsername(), user.getFirstName(), user.getLastName(), user.getAvatarUrl(), user.getEducationInstitution().getName(), null);
    }
}
