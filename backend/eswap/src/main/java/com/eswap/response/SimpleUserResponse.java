package com.eswap.response;

import com.eswap.common.constants.FollowStatus;
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
    private FollowStatus followStatus;

    public static SimpleUserResponse mapperToSimpleUserResponse(User user, FollowStatus followtSatus) {
        return new SimpleUserResponse(user.getId(), user.getUsername(), user.getFirstName(), user.getLastName(), user.getAvatarUrl(), user.getEducationInstitution().getName(), followtSatus);
    }
}
